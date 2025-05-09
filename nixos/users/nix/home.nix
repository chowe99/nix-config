# ~/nix-config/nixos/users/nix/home.nix
{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    vim git htop zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-fast-syntax-highlighting
    neofetch btop
    tree
  ];

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "1_shell";
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


  home.file.".zshrc".text = ''
    export EDITOR=vim
    export PATH=$HOME/bin:$PATH
    alias vim=lvim
  '';
}

