# Shared home configuration template for all users
# Shared home configuration template for all users
{ config, pkgs, lib, inputs, username, hostname, ... }:

{
  home.stateVersion = "24.11";
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    htop fastfetch btop tree home-manager lsd
  ];

  imports = [
    ../configs/zshrc.nix
  ];

  xdg.desktopEntries."superfile" = {
    name = "Superfile (TUI)";
    genericName = "TUI File Manager";
    comment = "Fast and modern TUI file manager";
    exec = "superfile";
    icon = "utilities-terminal";
    terminal = true;
    categories = [ "Utility" "FileTools" ];
    mimeType = [ "inode/directory" ];
  };

  programs.kitty.enable = true;

  # programs.ssh = {
  #   enable = true;
  #   authorizedKeys.keys = [
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOdjw3/8DiU7OBBvbzOSS9yc5PeIbReUizaYpI/Mqn7p whiteserver@whiteserver"
  #   ];
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
      alias vim=lvim
    '';
    force = true;
  };

  home.file.".config/rofi" = {
    source = "${inputs.dotfiles}/rofi";
    recursive = true;
  };
  home.file.".config/lvim" = {
    source = "${inputs.dotfiles}/lvim";
    recursive = true;
  };
  home.file.".config/waybar" = {
    source = "${inputs.dotfiles}/waybar";
    recursive = true;
  };
  home.file.".config/hypr" = {
    source = "${inputs.dotfiles}/hypr";
    recursive = true;
  };
}
