# dotfiles

My Apple Silicon Mac setup, managed with nix-darwin, Home Manager, nix-homebrew, Homebrew, and the Mac App Store. The repository is the source of truth for my machine: a fresh install should reproduce the applications, command-line tools, shell, editor, terminal, and macOS preferences I use.

## What this manages

- macOS defaults for appearance, keyboard repeat, the menu bar, Dock, Finder, and trackpad
- Homebrew formulae for machine-wide CLIs such as the AWS CLI, GitHub CLI, Git, Go, Just, OpenCode, and uv
- Homebrew casks for browsers, AI coding agents, Docker Desktop, Ghostty, messaging apps, Raycast, Spotify, VS Code, and WezTerm
- OpenSpec from its official Nix flake, installed through Home Manager
- Mac App Store installations for Apple applications and Xcode
- Home Manager packages for foundational CLIs such as ripgrep, fd, fzf, jq, lazygit, Neovim, and fnm
- Zsh, Starship, completions, aliases, autosuggestions, and syntax highlighting
- Neovim, WezTerm, and herdr configuration
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

### Migrating an existing shell

Home Manager owns the generated `~/.zshenv`, `~/.zprofile`, and `~/.zshrc`. Before the first switch on a machine with unmanaged versions of those files, move them to backup filenames so activation can create the managed files.

## Daily use

Edit the Nix configuration or a file under `home/`, then apply changes with:

```sh
./rebuild.sh
```

Files under `home/` are linked directly into the home directory, so edits to Neovim, WezTerm, herdr, and agent instructions take effect without a rebuild. Package lists, shell configuration, and system defaults require a rebuild.

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
- `home/` contains the live Neovim, WezTerm, herdr, and agent configuration linked into the home directory.

## Notes

The first Neovim launch bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) and downloads the pinned plugins in `home/.config/nvim/lazy-lock.json`. Neovim and WezTerm use the Rosé Pine Moon theme.

## Attribution

This repository began as [Kun Chen's dotfiles](https://github.com/kunchenguid/dotfiles). His [YouTube walkthrough](https://youtu.be/5N-okeDdIuI) explains the original structure and bootstrap flow. The configuration here has since been adapted to my applications, packages, shell, and preferences.

## License

Licensed under the MIT No Attribution license. See `LICENSE`.
