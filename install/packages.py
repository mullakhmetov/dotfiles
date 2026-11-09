#!/usr/bin/env python3
"""Preview or install the packages listed in packages.json."""

import argparse
import json
import os
from pathlib import Path
import platform
import re
import shlex
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request


ROOT = Path(__file__).resolve().parent
ARCHES = {"arm64": "aarch64", "aarch64": "aarch64", "amd64": "x86_64", "x86_64": "x86_64"}
SIGNING_KEY = "3FEF9748469ADBE15DA7CA80AC2D62742012EA22"


def host_target():
    arch = ARCHES.get(platform.machine().lower())
    if arch is None:
        raise ValueError("Unsupported processor architecture")
    if sys.platform == "darwin":
        return "macos", arch
    if sys.platform.startswith("linux"):
        release = Path("/etc/os-release").read_text()
        values = dict(line.split("=", 1) for line in release.splitlines() if "=" in line)
        family = (values.get("ID", "").strip("\"'") + " " +
                  values.get("ID_LIKE", "").strip("\"'")).split()
        if set(family) & {"arch", "archarm", "omarchy"}:
            return "arch", arch
    raise ValueError("This package catalog supports macOS and Arch Linux")


def load_catalog():
    return json.loads((ROOT / "packages.json").read_text())


def make_plan(catalog, target, arch, groups, only):
    known = {entry["id"] for entry in catalog}
    unknown = set(only) - known
    if unknown:
        raise ValueError("Unknown package: " + ", ".join(sorted(unknown)))
    plan = []
    for entry in catalog:
        selected = entry["id"] in only if only else (entry["group"] in groups or
                    ("all" in groups and entry["group"] != "optional"))
        if not selected:
            continue
        route = entry[target]
        if "method" not in route:
            route = route[arch]
        plan.append({**entry, **route})
    return plan


def run(args, **kwargs):
    print("+ " + shlex.join(args), flush=True)
    return subprocess.run(args, check=True, **kwargs)


def require(command):
    if not shutil.which(command):
        raise ValueError("Missing command: " + command)


def install_repo(packages):
    require("pacman")
    # Check the target's configured repositories before changing the system.
    available = []
    missing = []
    for package in packages:
        try:
            run(["pacman", "-Si", package], stdout=subprocess.DEVNULL)
            available.append(package)
        except subprocess.CalledProcessError:
            missing.append(package)
            print("Missing repository package: " + package, file=sys.stderr)
    if available:
        run(["sudo", "pacman", "-Syu", "--needed", *available])
    return missing


def read_url(url):
    request = urllib.request.Request(url, headers={"User-Agent": "dotfiles-installer"})
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def install_aur(package, base, arch):
    require("yay")
    if not re.fullmatch(r"[a-z0-9@+_.-]+", base):
        raise ValueError("Invalid AUR package base")
    info = read_url("https://aur.archlinux.org/cgit/aur.git/plain/.SRCINFO?h=" + base)
    sections = {None: set()}
    current = None
    for line in info.splitlines():
        key, separator, value = line.strip().partition(" = ")
        if separator and key == "pkgname":
            current = value
            sections[current] = set()
        elif separator and key == "arch":
            sections[current].add(value)
    architectures = sections.get(package) or sections[None]
    if package not in sections or not ({arch, "any"} & architectures):
        raise ValueError("AUR package " + package + " does not declare " + arch + " support")
    # Omarchy provides yay. Keep its build review and confirmation prompts.
    run(["yay", "-Syu", "--needed", package])


def download(url, destination):
    run(["curl", "--proto", "=https", "--proto-redir", "=https", "--tlsv1.2",
         "-fL", "-o", str(destination), url])


def install_script(entry):
    command = entry.get("command")
    if command and shutil.which(command):
        print("Already available: " + command + ". Use its updater for later versions.")
        return
    with tempfile.TemporaryDirectory(prefix="dotfiles-installer-") as directory:
        script = Path(directory) / "install.sh"
        download(entry["url"], script)
        args = [entry.get("shell", "sh"), str(script)]
        if entry.get("sudo"):
            args.insert(0, "sudo")
        run(args)


def install_onepassword():
    if shutil.which("1password"):
        print("Already available: 1password. Update the existing installation separately.")
        return
    destination = Path("/opt/1Password")
    if destination.exists() or destination.is_symlink():
        raise ValueError("Existing /opt/1Password needs manual review")
    require("gpg")
    require("curl")
    with tempfile.TemporaryDirectory(prefix="dotfiles-1password-") as directory:
        temporary = Path(directory)
        key = temporary / "1password.asc"
        archive = temporary / "1password.tar.gz"
        signature = temporary / "1password.tar.gz.sig"
        base = "https://downloads.1password.com/linux/tar/stable/aarch64/1password-latest.tar.gz"
        download("https://downloads.1password.com/linux/keys/1password.asc", key)
        download(base, archive)
        download(base + ".sig", signature)
        keyring = temporary / "gnupg"
        keyring.mkdir(mode=0o700)
        gpg = ["gpg", "--homedir", str(keyring), "--batch"]
        result = run(gpg + ["--with-colons", "--show-keys", str(key)], capture_output=True, text=True)
        if any(line.startswith(("sec:", "ssb:")) for line in result.stdout.splitlines()):
            raise ValueError("The 1Password signing material contains a secret key")
        fingerprints = [line.split(":")[9] for line in result.stdout.splitlines() if line.startswith("fpr:")]
        primary_keys = [line for line in result.stdout.splitlines() if line.startswith("pub:")]
        if len(primary_keys) != 1 or not fingerprints or fingerprints[0] != SIGNING_KEY:
            raise ValueError("The 1Password signing fingerprint differs")
        run(gpg + ["--import", str(key)])
        run(gpg + ["--verify", str(signature), str(archive)])
        extracted = temporary / "extracted"
        extracted.mkdir()
        with tarfile.open(archive) as bundle:
            # The signature authenticates the archive. Still reject unsafe paths.
            for member in bundle.getmembers():
                path = Path(member.name)
                if path.is_absolute() or ".." in path.parts:
                    raise ValueError("Unsafe path in 1Password archive")
                if member.issym() or member.islnk():
                    link = Path(member.linkname)
                    if link.is_absolute() or ".." in link.parts:
                        raise ValueError("Unsafe link in 1Password archive")
                elif not (member.isfile() or member.isdir()):
                    raise ValueError("Unexpected archive member")
            if hasattr(tarfile, "data_filter"):
                bundle.extractall(extracted, filter="data")
            else:
                bundle.extractall(extracted)
        roots = list(extracted.iterdir())
        if len(roots) != 1 or not (roots[0] / "after-install.sh").is_file():
            raise ValueError("Unexpected 1Password archive layout")
        missing = install_repo(["gtk3", "nss", "libsecret", "xdg-utils", "hicolor-icon-theme"])
        if missing:
            raise ValueError("Missing 1Password dependencies: " + ", ".join(missing))
        run(["sudo", "mkdir", str(destination)])
        run(["sudo", "cp", "-a", "--no-preserve=ownership", str(roots[0]) + "/.", str(destination)])
        run(["sudo", str(destination / "after-install.sh")])


def install_web(entry):
    root = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share")))
    path = root / "applications" / ("dotfiles-" + entry["id"] + ".desktop")
    content = ("[Desktop Entry]\nType=Application\nName=" + entry["title"] + " (Web)\n"
               "Exec=xdg-open " + entry["url"] + "\nTerminal=false\nCategories=Network;\n")
    if path.is_symlink() or (path.exists() and path.read_text() != content):
        raise ValueError("Existing browser launcher differs: " + str(path))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)


def apply_plan(plan, target, arch):
    if (target, arch) != host_target():
        raise ValueError("The selected target differs from this host. Use preview mode.")
    if hasattr(os, "geteuid") and os.geteuid() == 0:
        raise ValueError("Run this installer as your normal user, not root")
    failures = []
    unavailable = []
    repo_packages = list(dict.fromkeys(p for e in plan if e["method"] == "repo" for p in e["packages"]))
    if repo_packages:
        try:
            failures.extend(install_repo(repo_packages))
        except (ValueError, OSError, subprocess.CalledProcessError) as error:
            print("FAILED: system package transaction: " + str(error), file=sys.stderr)
            return 1
    for entry in plan:
        method = entry["method"]
        try:
            if method == "repo":
                continue
            if method in {"brew", "cask"}:
                require("brew")
                run(["brew", "install", *(["--cask"] if method == "cask" else []), *entry["packages"]])
            elif method == "aur":
                install_aur(entry["package"], entry["base"], arch)
            elif method == "script":
                install_script(entry)
            elif method == "onepassword":
                install_onepassword()
            elif method == "web":
                install_web(entry)
            elif method == "uv-tool":
                require("uv")
                run(["uv", "tool", "install", entry["package"]])
            elif method == "unavailable":
                unavailable.append(entry["id"])
            elif method != "none":
                raise ValueError("Unknown installation method: " + method)
        except (ValueError, OSError, subprocess.CalledProcessError) as error:
            failures.append(entry["id"])
            print("FAILED: " + entry["id"] + ": " + str(error), file=sys.stderr)
    print("Unavailable: " + (", ".join(unavailable) or "none"))
    print("Failed: " + (", ".join(failures) or "none"))
    return 1 if failures else 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--apply", action="store_true")
    mode.add_argument("--dry-run", action="store_true")
    parser.add_argument("--platform", choices=["macos", "arch"])
    parser.add_argument("--arch", choices=sorted(ARCHES))
    parser.add_argument("--group", action="append", choices=["core", "cli", "apps", "all"])
    parser.add_argument("--only", help="Comma-separated package IDs. Overrides group selection.")
    args = parser.parse_args(argv)
    try:
        if args.platform and args.arch:
            target, arch = args.platform, ARCHES[args.arch]
        else:
            actual_target, actual_arch = host_target()
            target, arch = args.platform or actual_target, ARCHES.get(args.arch, actual_arch)
        only = []
        if args.only is not None:
            only = [package.strip() for package in args.only.split(",")]
            if not all(only):
                raise ValueError("The --only option requires nonempty package IDs")
        plan = make_plan(load_catalog(), target, arch, args.group or ["core", "cli"], only)
        print("Target: " + target + "/" + arch)
        for entry in plan:
            details = entry.get("package") or " ".join(entry.get("packages", [])) or entry.get("url", "")
            print(entry["id"] + ": " + entry["title"] + " -> " + entry["method"] + " " + details)
            if entry.get("note"):
                print("  " + entry["note"])
        if args.apply:
            return apply_plan(plan, target, arch)
        print("Preview only. Use --apply on the target computer to install.")
        return 0
    except (ValueError, OSError) as error:
        print(str(error), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
