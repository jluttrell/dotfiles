# dotfiles

My Apple Silicon Mac setup, managed with nix-darwin, Home Manager, nix-homebrew, Homebrew, and the Mac App Store. The repository is the source of truth for my machine: a fresh install should reproduce the applications, command-line tools, shell, editor, terminal, and macOS preferences I use.

## What this manages

- macOS defaults for appearance, keyboard repeat, the menu bar, Dock, Finder, and trackpad
- Homebrew formulae for machine-wide CLIs and utilities such as the AWS CLI, GitHub CLI, Git, Go, Just, OpenCode, and uv
- Homebrew casks for browsers, AI coding agents, Docker Desktop, Ghostty, messaging apps, skhd, Spotify, VS Code, and WezTerm
- OpenSpec from its official Nix flake, installed through Home Manager
- Mac App Store installations for Apple applications and Xcode
- Home Manager packages for foundational CLIs such as ripgrep, fd, fzf, jq, lazygit, Neovim, and fnm
- Zsh, Starship, completions, aliases, autosuggestions, and syntax highlighting
- LazyVim, WezTerm, and herdr configuration
- Shared personal instructions for Claude Code, Codex, and OpenCode

The authoritative package lists are in `configuration.nix` and `home.nix`.

## Fresh-machine setup

Clone this repository on an Apple Silicon Mac:

```sh
git clone https://github.com/jo3luttrell/dotfiles.git
cd dotfiles
```

Open the App Store and sign in to your Apple Account before applying the configuration. Modern macOS does not provide a supported non-interactive App Store sign-in, so this authentication step cannot be automated. Once you are signed in, nix-darwin installs the applications declared in `homebrew.masApps` automatically.

Then run:

```sh
./bootstrap.sh
```

`bootstrap.sh`:

1. Installs Determinate Nix if needed.
2. Symlinks the checkout to `~/.dotfiles`, which is the stable path used by the Home Manager links.
3. Checks the username in `flake.nix` against the current macOS account and offers to update it if needed.
4. Runs the first `darwin-rebuild switch` for the `mac` configuration.

After the first switch, use the normal workflow below.

### Enable application shortcuts

Application shortcuts are managed by skhd. Homebrew installs the application during the first switch, but macOS requires the following one-time setup before the Caps Lock layer can work:

```sh
/Applications/skhd.app/Contents/MacOS/skhd --start-service
```

Approve the administrator prompt. This registers the user service and installs the root keyboard grabber and pinned Karabiner DriverKit package required by the Caps Lock hold rule. Run initial registration through the application bundle as shown above; the Homebrew `skhd` symlink cannot locate the bundled LaunchAgent during registration.

Activate the installed DriverKit extension:

```sh
/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate
```

Then complete these approvals in System Settings:

1. Under **General > Login Items & Extensions > Driver Extensions**, enable `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice`.
2. Under **Privacy & Security > Accessibility**, enable `skhd`. If it is absent, add `/Applications/skhd.app`.

Restart the services after enabling the DriverKit extension:

```sh
sudo launchctl kickstart -k system/org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon
sudo launchctl kickstart -k system/com.jackielii.skhd.grabber
/Applications/skhd.app/Contents/MacOS/skhd --restart-service
```

Test a shortcut, such as holding Caps Lock and pressing `J` to open Ghostty. macOS may not show a separate `skhd` entry under Input Monitoring; no manual entry is needed when the shortcuts work. If macOS does show an Input Monitoring prompt or entry, enable it.

Run `skhd --status` from a normal terminal for a setup summary. If the DriverKit manager application is missing or status reports that the HID daemon is not installed, run `/Applications/skhd.app/Contents/MacOS/skhd --install-dext`, then repeat the activation and restart steps above. Use `skhd --grabber-status` for detailed DriverKit, grabber, and keyboard matching diagnostics.

The application remains installed and upgraded through this repository. Only these privileged macOS approvals and service activations are manual; nix-darwin and Homebrew cannot grant them automatically.

### Migrating an existing shell

Home Manager owns the generated `~/.zshenv`, `~/.zprofile`, and `~/.zshrc`. During the first switch, any conflicting unmanaged files are automatically renamed with a `.backup` extension, such as `~/.zshrc.backup`, before the managed files are created.

## Daily use

Edit the Nix configuration or a file under `home/`, then apply changes with:

```sh
./rebuild.sh
```

Files under `home/` are linked directly into the home directory, so edits to Neovim, WezTerm, skhd, herdr, and agent instructions take effect without a rebuild. Package lists, shell configuration, and system defaults require a rebuild.

### Validate without applying

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

## Package ownership

Every tool has one package manager. Declaring the same tool in multiple places installs competing copies and makes `PATH` decide which one runs.

- Home Manager and Nixpkgs own foundational command-line tools that should follow `flake.lock`, plus programs whose Home Manager modules also own useful configuration.
- Homebrew owns native macOS applications and application-like tools that should track upstream releases more directly. This includes Claude Code, Codex, and OpenCode.
- `homebrew.masApps` owns Mac App Store applications.
- Project-specific runtimes and dependencies belong in the project or its Nix development shell rather than this machine-wide configuration.

Before adding a tool, search both package definitions and the enabled `programs.*` modules:

```sh
rg -n 'tool-name' home.nix configuration.nix
```

## Homebrew behavior

`nix-homebrew.autoMigrate = true` adopts an existing Homebrew installation when applying the configuration. Rebuilds install the formulae, casks, and Mac App Store applications declared in `configuration.nix`, but do not remove undeclared Homebrew packages, applications, or taps.

## Shell behavior

Home Manager generates the shell files from `home.nix`:

- Session variables and standard paths are managed declaratively.
- The generated login-shell profile initializes Homebrew through nix-homebrew's system link.
- Home Manager and Homebrew package completions are discovered through Zsh's completion system.
- The fzf module owns both the package and its Zsh integration.
- fnm switches Node versions from project version files. Node versions themselves remain project-specific and are not installed globally by this repository.

The `cc` and `co` aliases intentionally run Claude Code and Codex in high-agency modes. Review the commands in `home.nix` before using them in an unfamiliar repository.

## Repository layout

- `flake.nix` defines the pinned inputs, the `joe` account, and the `mac` nix-darwin configuration.
- `configuration.nix` contains macOS defaults and Homebrew/Mac App Store declarations.
- `home.nix` contains Home Manager packages, shell behavior, Starship, and links into `home/`.
- `bootstrap.sh` performs the first installation and switch.
- `rebuild.sh` applies later changes.
- `home/` contains the live Neovim, WezTerm, skhd, herdr, and agent configuration linked into the home directory.

## Notes

The first Neovim launch bootstraps the official [LazyVim](https://www.lazyvim.org/) starter and installs the plugin versions pinned in `home/.config/nvim/lazy-lock.json`. Run `:LazyHealth` after the initial installation to load and check every plugin. The configuration intentionally starts with LazyVim's defaults; add overrides under `home/.config/nvim/lua/config/` and plugin specs under `home/.config/nvim/lua/plugins/`.

## Attribution

This repository began as [Kun Chen's dotfiles](https://github.com/kunchenguid/dotfiles). His [YouTube walkthrough](https://youtu.be/5N-okeDdIuI) explains the original structure and bootstrap flow. The configuration here has since been adapted to my applications, packages, shell, and preferences.

## License

Licensed under the MIT No Attribution license. See `LICENSE`.
