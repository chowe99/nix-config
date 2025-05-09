# ~/nix-config/nixos/users/nix/home.nix
{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    vim git htop zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-fast-syntax-highlighting
    neofetch btop tree
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "simple";
      plugins = [ "git" "sudo" "z" ];
    };

    # Ensure completion is loaded correctly
    completionInit = ''
      autoload -U compinit
      compinit
    '';
  };

  programs.git = {
    enable = true;
    userName = "chowe99";
    userEmail = "chowej99@gmail.com";
  };

  home.file.".zshrc".text = ''
    export EDITOR=vim
    export PATH=$HOME/bin:$PATH
    alias vim=lvim

    # Oh My Posh init
    eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
  '';
}

