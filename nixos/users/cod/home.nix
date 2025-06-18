{ config, pkgs, lib, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = "aarch64-linux";
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "copilot.vim"
      ];
    };
  };
in
{
  # Set architecture and package set for aarch64-linux
  packageSet = unstable;
  cpu_architecture = "aarch64";

  # Import the base configuration
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ../../../configs/nixvim.nix
    ../../../templates/user-home.nix
  ];

  # Set nix package (exclusive to cod)
  nix.package = pkgs.nix;

  # Exclusive packages for aarch64-linux
  home.packages = with unstable; [
    openssh
    hyprpolkitagent
    brightnessctl
    pamixer
    xdg-utils
  ];

  # Exclusive session variables
  home.sessionVariables = {
    ELECTRON_DISABLE_GPU = "1";
  };

  # Exclusive session path
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Enable SSH (exclusive to cod)
  programs.ssh.enable = true;

  # Override rofi package (base uses packageSet, but cod needs unstable explicitly)
  programs.rofi.package = unstable.rofi-wayland;

  # Custom zsh configuration (overrides base)
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "simple";
      plugins = [ "git" "common-aliases" "colored-man-pages" "z" "dnf" "docker" "npm" "fzf" ];
    };
    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = unstable.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
    ];
  };

  # Custom .zshrc (overrides base)
  home.file.".zshrc" = {
    text = ''
      alias switch="home-manager switch --flake ~/nix-config#cod"
      export PATH="$HOME/Applications:$PATH"
    '';
    force = true;
  };
}
