# Applications and command-line tools

The catalog supports macOS and Arch Linux, including Omarchy on ARM64.
The package review date is 2026-11-09.
The current Mac tests installation logic, not Linux application behavior.

## Preview and install

Run commands from this checkout.
The package commands require Python 3.
The default mode shows proposed actions without downloads or configuration changes.
The `-B` option prevents Python bytecode caches during previews.

Preview the complete Omarchy ARM64 selection on your Mac:

```sh
python3 -B install/packages.py --platform arch --arch aarch64 --group all
```

On Omarchy, install tools, applications, and configuration:

```sh
bash install.sh --apply --with-apps
```

Install selected applications without changing dotfiles:

```sh
python3 -B install/packages.py --only 1password,1password-cli,herdr --apply
```

Use `--group core`, `--group cli`, or `--group apps` to select a group.
Use `--group all` to select all three groups.
The `--only` option overrides group selection.
The optional packages require explicit selection with `--only`.

Run the installer as your normal user.
Individual operations request `sudo` when necessary.
The installer rejects an installation target that differs from the current computer.
Omarchy must provide `yay` for AUR packages.
Install the complete selection first to supply shared dependencies such as curl and GnuPG.

## Omarchy ARM64 choices

| Package ID | Installation method |
| --- | --- |
| `1password` | Official ARM64 archive with signature verification |
| `1password-cli` | AUR `1password-cli` |
| `discord` | Browser launcher |
| `telegram` | Repository `telegram-desktop` |
| `v2rayn` | AUR `v2rayn-bin`, as the V2Box replacement |
| `zen` | AUR `zen-browser-bin` |
| `tailscale` | Repository `tailscale` |
| `sublime` | AUR `sublime-text-4` |
| `spotify` | Browser launcher |
| `obsidian` | AUR `obsidian-bin` |
| `codex-app` | Official OpenAI Arch installer for ChatGPT with Codex |
| `codex-cli` | Official Codex CLI installer |
| `claude-app` | Browser launcher |
| `claude-cli` | Official Claude Code installer |
| `ghostty` | Repository package, if the target provides it |
| `herdr` | Official Herdr app installer |
| `chrome` | AUR `google-chrome` |
| `ledger` | Unavailable on ARM64 |
| `lens` | Unavailable on ARM64 |
| `synology` | SMB access through `cifs-utils` and `gvfs-smb` |

Browser launchers open services in your default browser.
They do not install desktop applications.
The available Spotify, Ledger Wallet, Lens, and Synology Drive desktop packages target x86_64.
The catalog does not establish official Discord desktop support for Linux ARM64.
The official Claude desktop package supports Debian and Ubuntu, not Arch.
The installer does not select unofficial Discord or Claude desktop clients.

Ghostty availability depends on the target's repositories.
If its package is missing, other available packages can still install.
The installer reports Ghostty as failed and returns a nonzero exit code.
An explicit alternative builds the development revision from the AUR:

```sh
python3 -B install/packages.py --only ghostty-source --apply
```

Review its PKGBUILD and dependencies before accepting the build.
This option does not install the stable repository release.

Keep macOS or mobile access for Ledger Wallet.
For a terminal alternative to Lens, explicitly select `k9s`.
On x86_64 Arch, the catalog selects desktop packages for Discord, Spotify, Ledger Wallet, Lens, and Synology Drive.
On macOS, the catalog uses Homebrew where available and retains the existing V2Box app.

## Synology documents

Synology is the main document location.
The ARM64 Synology selection provides network access through SMB.
SMB does not synchronize files or provide offline copies.
A separate offline synchronization method still needs configuration on Omarchy.
Do not assume that an SMB mount works without a network connection.

On macOS, select **Synology Drive → Pin local copy permanently** for folders that require offline access.
Wait until downloads finish before checking those files without Wi-Fi.

## Command-line tools

The `core` group retains the shell and editor dependencies.
The `cli` group adds these tools:

- Kubernetes CLI, Helm, Terraform, AWS CLI v2, and AWS IAM Authenticator.
- Google Cloud CLI and gsutil.
- Docker, Docker Compose, Ansible, GitHub CLI, grpcurl, and HTTPie.
- PostgreSQL client tools, pgcli, pnpm, and age.
- autossh, wget, tree, watch, nmap, mtr, rsync, OpenSSH, gitleaks, and git-filter-repo.
- Xray, sing-box, 1Password CLI, Codex CLI, and Claude Code CLI.

Copier is optional: `python3 -B install/packages.py --only copier --apply`.
The selection does not install PostgreSQL, Redis, or MySQL servers.
On macOS, Docker commands require the existing OrbStack or another container engine.
The installer does not enable services, authenticate accounts, change VPN routes, or mount NAS folders.
Configure Docker and Tailscale service access separately.

The old `installation_scripts/brew.sh` now uses the same catalog.
It previews the macOS selection unless you supply `--apply`.
It no longer upgrades every Homebrew package automatically.

## Updates and limitations

Arch transactions use `pacman -Syu --needed` or `yay -Syu --needed` and retain confirmation prompts.
The installer checks AUR architecture declarations before installation.
The installer does not bypass package architecture checks or signatures.
The ARM64 1Password archive signature must match its trusted signing key.
That archive installation does not configure automatic updates.
Follow the vendor's instructions for later updates.

Upstream shell installers download to temporary files before execution.
Existing CLI commands remain installed.
Use their update commands for later versions.
The official OpenAI installer configures a signed repository and performs a full system upgrade.
Known unavailable packages appear in the summary but do not cause a failure exit code.
Missing repository packages and failed operations return a nonzero exit code.
When a package operation fails, `install.sh` stops before plugin installation and configuration links.
Correct the package failure, then repeat the installation command.
To apply configuration without installing packages, run `bash bootstrap.sh --apply`.
Credentials, wallet files, browser sessions, and VPN secrets remain outside this repository.

## Sources

- [1Password Linux installation](https://support.1password.com/install-linux/)
- [OpenAI desktop on Linux](https://learn.chatgpt.com/docs/linux/linux-app)
- [Codex CLI](https://learn.chatgpt.com/docs/codex/cli)
- [Claude desktop requirements](https://code.claude.com/docs/en/desktop-linux)
- [Claude Code installation](https://code.claude.com/docs/en/setup)
- [Herdr downloads](https://herdr.dev/download/)
- [v2rayN releases](https://github.com/2dust/v2rayN/releases)
- [Zen Linux installation](https://docs.zen-browser.app/guides/install-linux)
- [Ghostty prerelease installation](https://ghostty.org/docs/install/pre)
- [Ghostty ARM64 package limitation](https://github.com/omacom/try-omarchy/issues/137)
- [Telegram ARM64 package](https://archlinuxarm.org/packages/aarch64/telegram-desktop)
- [Terraform ARM64 package](https://archlinuxarm.org/packages/aarch64/terraform)
- [sing-box ARM64 package](https://archlinuxarm.org/packages/aarch64/sing-box)
- [Lens requirements](https://docs.lenshq.io/k8slens/getting-started/install-lens/)
- [Synology Drive requirements](https://www.synology.com/en-global/dsm/7.4/software_spec/synology_drive)
- [Synology offline copies](https://kb.synology.com/en-global/PAS/help/SynologyDriveClient/synologydriveclient)
