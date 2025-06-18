{ config, pkgs, lib, inputs, username, hostname, ... }:

{
  # Define custom options
  options = {
    packageSet = lib.mkOption {
      type = lib.types.attrs;
      default = pkgs;
      description = "The package set to use for installing packages";
    };
    cpu_architecture = lib.mkOption {
      type = lib.types.str;
      default = if pkgs.system == "aarch64-linux" then "aarch64" else "x86_64";
      description = "CPU architecture for Flatpak and other tools";
    };
  };

  config = {
    # Set packageSet based on system
    packageSet = if pkgs.system == "aarch64-linux" 
                 then inputs.nixpkgs-unstable.legacyPackages.${pkgs.system} 
                 else pkgs;

    home.stateVersion = "24.11";
    home.username = username;
    home.homeDirectory = "/home/${username}";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    home.packages = with config.packageSet; [
      vim git htop zsh
      btop
      tree home-manager
      docker
      signal-desktop
      wineWowPackages.waylandFull
      papirus-icon-theme
      winetricks
      dpkg
      libcanberra
      lsd
      nix-prefetch-git
      wl-clipboard
      oh-my-posh
      waybar
      fastfetch
      hyprshot
      superfile
      wget
      libcanberra
      nss
      gtk2
      udiskie
      libnotify
      exfatprogs
      pywal
      hyprpaper
      swww
      ffmpeg-full
      yt-dlp
      mullvad-vpn
      flatpak
    ];

    # Example Flatpak desktop entry using cpu_architecture
    xdg.desktopEntries."md.obsidian.Obsidian" = {
      name = "Obsidian";
      exec = "flatpak run --no-sandbox --branch=stable --arch=${config.cpu_architecture} --command=obsidian.sh md.obsidian.Obsidian";
      icon = "md.obsidian.Obsidian";
      type = "Application";
    };

    programs.rofi = {
      enable = true;
      package = config.packageSet.rofi-wayland;
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
          src = config.packageSet.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }
        {
          name = "zsh-syntax-highlighting";
          src = config.packageSet.zsh-syntax-highlighting;
          file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        }
        {
          name = "fast-syntax-highlighting";
          src = config.packageSet.zsh-fast-syntax-highlighting;
          file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        }
      ];
    };

    # Rest of the configuration remains unchanged
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
        alias rebuild="sudo nixos-rebuild switch --flake ~/nix-config#${username}"
        alias ssf2='wine "$HOME/.wine/drive_c/Program Files (x86)/Super Smash Flash 2 Beta/SSF2.exe"'
        alias c="clear && fastfetch"
        alias open="superfile"
        alias ls='lsd'
        alias l='ls -l'
        alias la='ls -a'
        alias lla='ls -la'
        alias lt='ls --tree'
        fastfetch
        if [[ -f /run/agenix/openai-api-key ]]; then
          export OPENAI_API_KEY=$(cat /run/agenix/openai-api-key)
        fi
        if [[ -f /run/agenix/gemini-api-key ]]; then
          export GEMINI_API_KEY=$(cat /run/agenix/gemini-api-key)
        fi
        if [[ -f /run/agenix/anthropic-api-key ]]; then
          export ANTHROPIC_API_KEY=$(cat /run/agenix/anthropic-api-key)
        fi
      '';
      force = true;
    };

    # File imports and other settings unchanged
    home.file.".config/rofi".source = "${inputs.dotfiles}/rofi";
    home.file.".config/rofi".recursive = true;
    home.file.".config/lvim".source = "${inputs.dotfiles}/lvim";
    home.file.".config/lvim".recursive = true;
    home.file.".config/waybar".source = "${inputs.dotfiles}/waybar";
    home.file.".config/waybar".recursive = true;
    home.file.".config/hypr".source = "${inputs.dotfiles}/hypr";
    home.file.".config/hypr".recursive = true;
    home.file.".config/kitty".source = "${inputs.dotfiles}/kitty";
    home.file.".config/kitty".recursive = true;
  };
}
