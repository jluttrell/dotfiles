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

  # Keep long-running local tasks alive while connected to power, even after
  # locking or display sleep. The charger-only flag preserves normal battery
  # sleep behavior.
  system.activationScripts.postActivation.text = ''
    echo "configuring charger power management..." >&2
    /usr/bin/pmset -c sleep 0
  '';

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
    universalaccess.reduceMotion = true;  # reduce Spaces and app animations
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
    taps = [
      "jackielii/tap"
      "largemodgames/spotatui"
    ];
    brews = [
      "awscli"
      "gh"
      "git"
      "go"
      "herdr"
      "just"
      "lazygit"
      "homebrew/core/opencode"
      "largemodgames/spotatui/spotatui"
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
      "jackielii/tap/skhd-zig"
      "opencode-desktop"
      "rectangle"
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
