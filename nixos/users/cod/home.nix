{ config, pkgs, lib, inputs, ... }:

{
  home.stateVersion = "24.11";
  home.username = "cod"; # Update to your cod username
  home.homeDirectory = "/home/cod"; # Update to your cod home directory
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = pkgs.nix;

  home.packages = with pkgs; [
    wl-clipboard # wayland clipboard
    openssh
    oh-my-posh wofi waybar vim htop zsh
    neofetch btop
    tree home-manager
    hyprshot # screenshots
    hyprpolkitagent # authentication agent
    papirus-icon-theme
    wget
    udiskie # disk management
    exfatprogs # Support for exFAT filesystems
    pywal # For color schemes
    hyprpaper # For setting wallpaper
    swww # For setting animated wallpaper
    ffmpeg-full # For video/audio processing
    yt-dlp # For downloading videos
    superfile # Terminal file manager
    brightnessctl # brightness control
    pamixer # audio control
    flatpak # for certain applications (bitwarden, obsidian, etc)
    xdg-utils # for xdg-settings (fixes Obsidian error)

    # --- For Lvim ---
    (neovim.override {
          vimAlias = true;
          configure = {
            customRC = ''
              set number
            '';
            packages.myPlugins = with pkgs.vimPlugins; {
              start = [ nvim-lspconfig ];
            };
          };
    })
    lunarvim
    libnotify # library for notify-send in lvim
    yarn
    nodejs
    cargo
    ripgrep
    perl
    openssl
    black
    nodePackages.stylelint
    shfmt
    nodePackages.eslint_d
    python3Packages.pylint
    shellcheck
  ];

  home.sessionVariables = {
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
    ELECTRON_DISABLE_GPU = "1"; # Mitigate Asahi GPU issues
  };

  #Add support for ./local/bin
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

# Flatpak configuration
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "md.obsidian.Obsidian"
      "com.bitwarden.desktop"
      "app.zen_browser.zen"
      "com.github.tchx84.Flatseal"
    ];
    uninstallUnmanaged = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };

  xdg.desktopEntries = {
    "md.obsidian.Obsidian" = {
      name = "Obsidian";
      comment = "Knowledge base";
      exec = "flatpak run --no-sandbox --branch=stable --arch=aarch64 --command=obsidian.sh --file-forwarding md.obsidian.Obsidian --js-flags=\"--nodecommit_pooled_pages\" --disable-gpu @@u %U @@";
      icon = "md.obsidian.Obsidian";
      terminal = false;
      type = "Application";
      categories = [ "Office" ];
      mimeType = [ "x-scheme-handler/obsidian" ];
    };
    "superfile" = {
      name = "Superfile (TUI)";
      genericName = "TUI File Manager";
      comment = "Fast and modern TUI file manager";
      exec = "superfile";
      icon = "utilities-terminal";
      terminal = true;
      categories = [ "Utility" "FileTools" ];
      mimeType = [ "inode/directory" ];
    };
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

  programs.ssh.enable = true;

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
      export EDITOR=lvim
      alias vim=lvim
      # alias age=agenix
      eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
      alias switch="home-manager switch --flake ~/nix-config#cod" # Updated for Home Manager
      alias c="clear && neofetch"
      alias open="superfile"
      neofetch
      export PATH="$HOME/Applications:$PATH"
      # wal -R
    '';
    force = true;
  };

  home.file.".config/rofi" = {
    source = "${inputs.dotfiles}/rofi";
    recursive = true;
  };
  #home.file.".config/lvim" = {
  #  source = "${inputs.dotfiles}/lvim";
  #  recursive = true;
  #};
  home.file.".config/waybar" = {
    source = "${inputs.dotfiles}/waybar";
    recursive = true;
  };
  home.file.".config/hypr" = {
    source = "${inputs.dotfiles}/hypr";
    recursive = true;
  };
  home.file.".config/kitty" = {
    source = "${inputs.dotfiles}/kitty";
    recursive = true;
  };
}
