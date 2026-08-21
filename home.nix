{ config, openspec, pkgs, treehouse, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    jq        # json on the command line
    lazygit
    neovim
    tree-sitter
    fnm
    openspec.packages.${pkgs.stdenv.hostPlatform.system}.default
    treehouse.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  fonts.fontconfig.enable = true;
  home.sessionPath = [ "$HOME/go/bin" ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;           # discover completions shipped by packages
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    profileExtra = ''
      eval "$(/run/current-system/sw/bin/brew shellenv)"
    '';
    initContent = ''
      bindkey '^f' autosuggest-accept

      # The Nixpkgs lazygit package has a generator, but no completion file.
      eval "$(${pkgs.lazygit}/bin/lazygit completion zsh)"

      # Nixpkgs ships fnm's completion; this hook manages Node version switching.
      eval "$(${pkgs.fnm}/bin/fnm env --use-on-cd --shell zsh)"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --approve-for-me";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".config/skhd".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/skhd";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
