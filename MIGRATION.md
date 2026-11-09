# Omarchy migration

## Target and current scope

The target is a MacBook Pro 14-inch with M1 Pro, 16 GB memory, and a 500 GB internal SSD.
The owner plans to test Omarchy 4.5 alongside macOS.

The owner supplied these requirements on 2026-11-08:

- The owner uses no external monitor or dock.
- Ghostty is the active terminal and uses its standard configuration.
- Raycast only starts applications.
- Karabiner maps Caps Lock to Ctrl.
- The owner uses zsh, Neovim, tmux, and Atuin.
- The owner uses Pages and Numbers for simple document changes and PDF exports.
- The owner will organize iCloud files and duplicate necessary work files to Synology.

The owner does not use cmux, iTerm, DataGrip, or LuckGrib.
CryptoPro, Rutoken, and cptools are outside the initial migration.
The owner permits removal of the Sensus updater.

## Preserve working habits

Keep Ghostty as the terminal.
Use the Omarchy application launcher for the existing Raycast task.
Review any Ghostty configuration that Omarchy supplies before choosing upstream defaults.

After checking the new shell on Omarchy, select zsh as the login shell:

```sh
chsh -s /usr/bin/zsh
```

End the desktop session before testing the new login shell.

The file `omarchy/input.conf` records the Caps Lock to Ctrl option.
Merge `ctrl:nocaps` into the existing Hyprland input configuration.
Preserve other keyboard options and the current keyboard layout.
The bootstrap script does not replace the Omarchy desktop configuration.

The current Karabiner profile also contains Fn-H and Fn-L deletion rules.
The owner only requested Caps Lock to Ctrl for this migration.

## Transfer configurations and private state separately

The repository stores configuration, plugin specifications, and the Neovim plugin lock file.
It excludes command history, authentication sessions, encryption keys, caches, and downloaded plugins.

Before changing operating systems:

1. Check that the repository contains the current configuration.
2. Create an independent backup of files that Git does not store.
3. Check access to 1Password from the new operating system.
4. Transfer SSH access and work credentials through their existing credential stores.
5. Check Atuin history synchronization or prepare an encrypted offline backup.
6. Check that necessary Synology files remain available without a network connection.

Atuin configuration does not contain the history database or encryption key.
Keep its encryption key and account recovery information outside Git.
The shell retains `atuin init zsh --disable-up-arrow` and the existing Enter behavior.

Do not copy all of `~/.config`.
That directory contains account credentials and machine-specific application state.
Do not copy all of `~/.local/share` into the repository.

## Documents and PDF files

Test LibreOffice Writer and Calc with representative documents and spreadsheets.
Test LibreOffice Draw for simple PDF edits and a visible signature image.
A visible signature image is different from a certificate-based digital signature.
The initial migration does not include qualified electronic signatures.

Export important Pages documents to DOCX and PDF before migration.
Export important Numbers spreadsheets to XLSX and PDF before migration.
Retain the original Apple files.
Check fonts, page breaks, formulas, and PDF appearance after conversion.

References:

- [LibreOffice Draw guide](https://documentation.libreoffice.org/assets/Uploads/Documentation/en/DG7.5/DG75-DrawGuide.pdf)
- [Hyprland keyboard configuration](https://wiki.hypr.land/configuring/core/binds/)

## Synology and iCloud

On 2026-11-09, the owner selected Synology as the main document location.
Use Synology `Documents` for future document edits.
The NAS contains the combined document collection from the local Documents folder and iCloud Documents.
The retained iCloud copies do not automatically receive changes from Synology.

The NAS stores recovery files under `Documents/Personal/Recovery`.
The 1Password Emergency Kit also remains in the corresponding iCloud folder.
Keep recovery secrets outside this repository.

Configure local copies of necessary documents for use without internet access.
SMB access requires a network connection.
Test an offline workflow before relying on the Linux laptop during travel.
Check whether NAS backups preserve earlier file versions before relying on recovery after accidental deletion.

The current Mac has one configured Obsidian vault outside iCloud.
Check its current synchronization method before moving the vault.
Do not enable multiple synchronization tools for the same vault.

## Validation before daily use

1. Start a fresh zsh session and check the expected commands.
2. Check Atuin search and history synchronization.
3. Check tmux sessions, Ctrl-Q, clipboard operations, and the production session color.
4. Check Neovim startup, completion, diagnostics, formatting, and tests.
5. Check work access, private DNS, and Synology access at home and outside home.
6. Complete a video call with screen sharing.
7. Check battery use and network recovery after sleep.
8. Edit and export representative documents.
9. Restore a file from the independent backup.

This change does not establish native Omarchy hardware compatibility.
Run the Linux package installer and desktop checks on the target installation.
The imported Neovim plugins retain their existing revisions.
Their compatibility with the target Neovim version still requires a target-machine check.
