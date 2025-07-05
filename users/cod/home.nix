{ config, pkgs, lib, inputs, username, hostname, ... }:
{
  # Import the base configuration
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ../../configs/nixvim.nix
    ../../templates/user-home.nix
  ];

  # Set nix package (exclusive to cod)
  nix.package = pkgs.nix;

  # Exclusive packages for aarch64-linux
  home.packages = with config.packageSet; [
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
        src = config.packageSet.zsh-fast-syntax-highlighting;
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
