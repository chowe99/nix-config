{ config, pkgs, lib, inputs, ... }:

{
  home.stateVersion = "24.11";
  home.username = "cod"; # Update to your cod username
  home.homeDirectory = "/home/cod"; # Update to your cod home directory
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = pkgs.nix;

  home.packages = with pkgs; [
    oh-my-posh lunarvim wofi waybar vim htop zsh
    neofetch btop
    tree home-manager
    hyprshot # screenshots
    papirus-icon-theme
    wget
    udiskie
    libnotify
    exfatprogs # Support for exFAT filesystems
    pywal # For color schemes
    hyprpaper # For setting wallpaper
    swww # For setting animated wallpaper
    ffmpeg-full # For video/audio processing
    yt-dlp # For downloading videos
    superfile # Terminal file manager
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

  # udiskie configuration for mounting partitions
  services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "never"; # Correct value for Hyprland
      settings = {
        program_options = {
          password_prompt = "kitty -e udiskie-unlock"; # Prompt in kitty for LUKS passphrase
        };
        device_config = [
          # Unencrypted exFAT partition (sda1)
          {
            device = "UUID=BF75-E4C0";
            automount = true;
          }
          # LUKS-encrypted partition (sda3)
          {
            device = "UUID=73535e6c-db20-4edb-9a7d-3fe4f869b924";
            luks = true;
            automount = true;
          }
        ];
      };
    };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus";
    };
  };

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
      # alias age=agenix
      eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
      alias switch="home-manager switch --flake ~/nix-config#cod" # Updated for Home Manager
      alias c="clear && neofetch"
      alias open="superfile"
      neofetch
      wal -R
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
