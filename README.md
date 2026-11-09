# Dotfiles

These files configure zsh, Git, tmux, Neovim, and Atuin.
The installer supports macOS, Arch Linux, Omarchy, and the existing Ubuntu setup.
Omarchy uses the Arch installer, including on ARM64.

## Review the configuration

Run these commands from this repository:

```sh
bash install.sh --dry-run
bash bootstrap.sh --dry-run
```

Both commands only show proposed actions.
Neither command installs packages or changes configuration.

## Apply the configuration

Install missing tools and apply the configuration:

```sh
bash install.sh --apply
```

The Arch installer performs a full system upgrade before it installs missing packages.
Review the package transaction before accepting the pacman prompt.
The macOS installer requires Homebrew.
The Ubuntu installer retains its interactive component selection.

Apply configuration without installing packages:

```sh
bash bootstrap.sh --apply
```

The bootstrap script creates symbolic links to this checkout.
Keep the checkout at its current location after you apply the configuration.
The script preserves existing files, directories, and different symbolic links in a backup directory.
Repeated applications preserve links that already point to this checkout.

Backups use this directory:

```text
${XDG_STATE_HOME:-~/.local/state}/dotfiles/backups/
```

Each backup contains a tab-separated manifest with the original path and backup path.
To restore a file, remove its new symbolic link.
Then move the corresponding backup to its original path.
Do not remove a directory unless you first check its contents.

## Configuration scope

| Component | Source | Destination |
| --- | --- | --- |
| zsh | `zsh/` | `~/.zshrc`, `~/.zshenv`, `~/.zprofile`, `~/.zsh/` |
| Git | `git/` | `~/.gitconfig`, `~/.gitignore_global` |
| tmux | `tmux/` | `~/.tmux.conf`, `~/.tmux/` helpers |
| Neovim | `nvim/` | `$XDG_CONFIG_HOME/nvim` |
| Atuin | `atuin/config.toml` | `$XDG_CONFIG_HOME/atuin/config.toml` |

The default XDG configuration directory is `~/.config`.
The bootstrap script leaves Ghostty, Hyprland, Karabiner, and application credentials unchanged.
The optional `--with-claude` argument also links the existing Claude configuration.
Review that configuration before using the argument.

The shell accepts machine-specific settings from `~/.zshrc.local` and `~/.zprofile.local`.
Keep credentials outside Git.
The Linux `cxm` helper accepts a 1Password reference through `MIRAI_GITHUB_PAT_REF`.
Without that reference, macOS retains its existing Keychain lookup.

## Plugins and editor tools

The package installer preserves existing Oh My Zsh and tmux plugin directories.
It clones missing plugin managers and zsh plugins from their upstream repositories.
These shell plugin clones follow upstream versions.

After starting tmux, press the configured prefix, Ctrl-Q, followed by Shift-I.
TPM then installs the tmux plugins.
Neovim retains the imported `lazy-lock.json`.
Use `:Lazy restore` to restore its plugin revisions.
Mason installs language servers separately for each operating system and processor architecture.
Tree-sitter also rebuilds its parsers.
Do not copy the macOS plugin binaries or Mason executables to Linux.

The default shell does not change on macOS or Arch.
Test `zsh` before selecting it as your login shell.

## Checks

The regression tests require Python 3 and zsh.

```sh
python3 -m unittest discover -s tests -v
```

The tests use temporary home directories.
The installer preview test blocks package managers and network commands.

See [the Omarchy migration notes](MIGRATION.md) for the migration scope and remaining checks.
