{ config, lib, openspec, pkgs, treehouse, user, ... }:

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
    delta
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

      # Lazygit's Homebrew formula does not ship completion files.
      eval "$(lazygit completion zsh)"

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

  # Edit-in-place: the real files stay in my repo, home directory links point at them.
  home.file."Library/Application Support/lazygit/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/lazygit/config.yml";
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
  home.file.".config/rectangle".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/rectangle";

  # Rectangle consumes and renames its startup import, so stage a fresh copy.
  home.activation.rectangleConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run mkdir -p "$HOME/Library/Application Support/Rectangle"
    run cp "$HOME/.config/rectangle/RectangleConfig.json" \
      "$HOME/Library/Application Support/Rectangle/RectangleConfig.json"
  '';

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
