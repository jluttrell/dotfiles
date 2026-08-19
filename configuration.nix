{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      # _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    # Adopt an existing Homebrew installation when applying this config.
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.autoUpdate = false;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "awscli"
      "gh"
      "git"
      "go"
      "herdr"
      "just"
      "homebrew/core/opencode"
      "tree"
      "uv"
    ];
    casks = [
      "brave-browser"
      "chatgpt"
      "claude-code"
      "codex"
      "discord"
      "docker-desktop"
      "firefox"
      "ghostty"
      "google-chrome"
      "opencode-desktop"
      "raycast"
      "slack"
      "spotify"
      "topnotch"
      "visual-studio-code"
      "wezterm"
      "whatsapp"
    ];
    masApps = {
      GarageBand = 682658836;
      iMovie = 408981434;
      Keynote = 361285480;
      Numbers = 361304891;
      Pages = 361309726;
      Xcode = 497799835;
    };
  };
}
