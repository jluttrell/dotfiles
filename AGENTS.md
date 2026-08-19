# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- Give every tool one owner. Use Home Manager/Nixpkgs for foundational CLIs that should follow `flake.lock` and for user-level program modules; use Homebrew for native macOS apps and application-like tools meant to track upstream releases, including AI coding agents. GUI versus CLI alone is not decisive. Keep project-specific toolchains in the owning project or its Nix development shell. Before adding anything, check `home.packages`, enabled `programs.*`, and `homebrew.brews`/`casks`; never declare the same tool twice.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
