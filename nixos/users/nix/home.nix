# ~/nix-config/nixos/users/nix/home.nix
{ config, pkgs, lib, inputs, ... }:

let
  # Helper to safely construct the export line for Gemini API Key
  geminiApiKeyExport =
    if config ? age && config.age ? secrets && config.age.secrets ? "gemini-api-key" && config.age.secrets."gemini-api-key" ? path
    then ''export GEMINI_API_KEY="$(<${config.age.secrets."gemini-api-key".path})"''
    else ""; # Or lib.warn "Gemini API Key path not found" ""

  # Helper for OpenAI API Key
  openaiApiKeyExport =
    if config ? age && config.age ? secrets && config.age.secrets ? "openai-api-key" && config.age.secrets."openai-api-key" ? path
    then ''export OPENAI_API_KEY="$(<${config.age.secrets."openai-api-key".path})"''
    else "";

  # Helper for Anthropic API Key
  anthropicApiKeyExport =
    if config ? age && config.age ? secrets && config.age.secrets ? "anthropic-api-key" && config.age.secrets."anthropic-api-key" ? path
    then ''export ANTHROPIC_API_KEY="$(<${config.age.secrets."anthropic-api-key".path})"''
    else "";

  # configDir = ./config; # Path to the config directory relative to this file
  # configEntries = builtins.readDir configDir; # Read contents of the directory
  # lib = pkgs.lib; # Make lib available in this let block

  # # Filter for directories and map them to environment.etc attributes with correct keys
  # generatedEtcAttrs = lib.mapAttrs' (name: type:
  #   if type == "directory" then
  #     {
  #       # New key is the target path
  #       name = "home/nix/.config/${name}";
  #       # Value is the source attribute set
  #       value = { source = configDir + "/${name}"; };
  #     }
  #   else
  #     null # Skip non-directories
  # ) configEntries;
in
{
  home.stateVersion = "24.11";
  home.username = "nix"; # Set the username
  home.homeDirectory = "/home/nix"; # Set the home directory
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home.packages = with pkgs; [
    vim git htop zsh
    neofetch btop
    tree home-manager
    docker
    superfile
    signal-desktop
    wineWowPackages.waylandFull
    # Helper tool to pull in common dlls
    winetricks
    dpkg
    libcanberra

    # Opptional: native wget so dpkg-query --find returns something
    wget
    # replace libcanberra-gtk_module, libnss3 etc with Nix packages:
    libcanberra
    nss
    gtk2
  ];

  # xdg.desktopEntries."superfile" = {
  #   name = "Superfile (TUI)";
  #   genericName = "TUI File Manager";
  #   comment = "Fast and modern TUI file manager";
  #   exec = "kitty -e \'zsh -c superfile\;\$SHELL\'"; # Adjust binary name if needed
  #   icon = "utilities-terminal"; # Or "superfile-fm" if icon provided
  #   terminal = false; # <<<--- THIS IS THE CRUCIAL CHANGE
  #   categories = ["Utility" "FileTools" "ConsoleOnly" "System"];
  #   mimeType = ["inode/directory"];
  # };

  programs.kitty.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    # Use Hyprland and xdg-desktop-portal-hyprland from NixOS module
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    package = pkgs.hyprland;
    # portalPackage = null;
    # Load custom configuration
    # This assumes hyprland.conf is in the same directory as home.nix
    extraConfig = builtins.readFile ./hyprland.conf;
    # Optional: If you have issues with systemd services not finding programs
    # systemd.variables = ["--all"];
  };


  # age.secrets = {
  #   "gemini-api-key".file = ./secrets/gemini-api-key.age;
  # };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "simple";
      plugins = [ "git" "common-aliases" "colored-man-pages" "z" ];
    };
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
    ];
  };

  programs.git = {
    enable = true;
    userName = "chowe99";
    userEmail = "chowej99@gmail.com";
  };

  home.file.".zshrc" = {
    text = ''
      export EDITOR=vim
      alias vim=lvim
      alias age=agenix
      eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
      alias rebuild="sudo nixos-rebuild switch --flake ~/nix-config#nix"
      alias ssf2='wine "$HOME/.wine/drive_c/Program Files (x86)/Super Smash Flash 2 Beta/SSF2.exe"'
      ${geminiApiKeyExport}
      ${anthropicApiKeyExport}
      ${openaiApiKeyExport}
    '';
    force = true;
  };

  home.file.".config/waybar" = {
    source    = inputs.waybar-config;
    recursive = true;
    force = true;
  };
  home.file.".config/lvim" = {
    source    = inputs.lvim-config;
    recursive = true;
    force = true;
  };

  # Dynamically generate environment.etc entries for config directories
  # environment.etc = generatedEtcAttrs;

}

