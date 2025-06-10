{ config, pkgs, lib, inputs, ... }:

{
  home.stateVersion = "24.11";
  home.username = "cod"; # Update to your cod username
  home.homeDirectory = "/home/cod"; # Update to your cod home directory
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home.packages = with pkgs; [
    vim git htop zsh
    neofetch btop
    tree home-manager
    docker
    signal-desktop
    # wineWowPackages.waylandFull # May not work well on Asahi; test or remove
    papirus-icon-theme
    # winetricks
    dpkg
    libcanberra

    wget
    libcanberra
    nss
    gtk2
    udiskie
    libnotify
    exfatprogs
    pywal
    # hyprpaper # Optional; depends on Hyprland
    # swww # Optional; depends on Hyprland
    ffmpeg-full
    yt-dlp
    mullvad-vpn
  ];

  # xdg.desktopEntries."superfile" = {
  #   name = "Superfile (TUI)";
  #   genericName = "TUI File Manager";
  #   comment = "Fast and modern TUI file manager";
  #   exec = "superfile";
  #   icon = "utilities-terminal";
  #   terminal = true;
  #   categories = [ "Utility" "FileTools" ];
  #   mimeType = [ "inode/directory" ];
  # };

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

  programs.kitty.enable = true;

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
      alias rebuild="home-manager switch --flake ~/nix-config#cod" # Updated for Home Manager
      # alias ssf2='wine "$HOME/.wine/drive_c/Program Files (x86)/Super Smash Flash 2 Beta/SSF2.exe"' # Test or remove
      alias c="clear && neofetch"
      alias open="superfile"
      neofetch
      # Adjust API key paths for Asahi Linux
      # if [[ -f ~/.config/secrets/openai-api-key ]]; then
      #   export OPENAI_API_KEY=$(cat ~/.config/secrets/openai-api-key)
      # fi
      # if [[ -f ~/.config/secrets/gemini-api-key ]]; then
      #   export GEMINI_API_KEY=$(cat ~/.config/secrets/gemini-api-key)
      # fi
      # if [[ -f ~/.config/secrets/anthropic-api-key ]]; then
      #   export ANTHROPIC_API_KEY=$(cat ~/.config/secrets/anthropic-api-key)
      # fi
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
