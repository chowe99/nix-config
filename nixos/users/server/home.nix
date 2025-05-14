# ~/nix-config/nixos/users/server/home.nix
{ config, pkgs, lib, inputs, ... }:

{
  home.stateVersion = "24.11";
  home.username = "server"; # Set the username
  home.homeDirectory = "/home/server"; # Set the home directory
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home.packages = with pkgs; [
    vim git htop zsh
    neofetch btop
    tree home-manager
    docker
    superfile
  ];

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
      alias rebuild="sudo nixos-rebuild switch --flake ~/nix-config#server"
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

}

