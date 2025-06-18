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
  imports = [ 
    inputs.nixvim.homeManagerModules.nixvim 
    ../../../configs/nixvim.nix
  ];
  home.stateVersion = "24.11";
  home.username = "cod";
  home.homeDirectory = "/home/cod";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = pkgs.nix;

  home.packages = with unstable; [
    lsd
    nix-prefetch-git
    wl-clipboard
    openssh
    oh-my-posh wofi waybar vim htop
    fastfetch btop
    tree home-manager
    hyprshot
    hyprpolkitagent
    papirus-icon-theme
    wget
    udiskie
    exfatprogs
    pywal
    hyprpaper
    swww
    ffmpeg-full
    yt-dlp
    superfile
    brightnessctl
    pamixer
    flatpak
    xdg-utils

    # Dependencies for NixVim
    eslint_d
    pylint
    stylelint
    shellcheck
    prettierd
    black
    shfmt
    ripgrep
    fd
    gnumake
    gcc
    nodejs
    yarn
    cargo
    perl
    openssl
    libnotify
    nodePackages.graphql-language-service-cli  
    go
    php
    luarocks
    openjdk
    julia
  ];

  home.sessionVariables = {
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
    ELECTRON_DISABLE_GPU = "1";
    EDITOR = "nvim";
  };

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

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
    settings = {
      program_options = {
        password_prompt = "kitty -e udiskie-unlock";
      };
      device_config = [
        {
          device = "UUID=BF75-E4C0";
          automount = true;
        }
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
    package = unstable.rofi-wayland;
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus";
    };
  };

  programs.git = {
    enable = true;
    userName = "chowe99";
    userEmail = "chowej99@gmail.com";
  };

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


  home.file.".zshrc" = {
    text = ''
      export EDITOR=nvim
      alias vim=nvim
      eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
      alias switch="home-manager switch --flake ~/nix-config#cod"
      alias c="clear && fastfetch"
      alias open="superfile"
      alias ls='lsd'
      alias l='ls -l'
      alias la='ls -a'
      alias lla='ls -la'
      alias lt='ls --tree'
      fastfetch
      export PATH="$HOME/Applications:$PATH"
    '';
    force = true;
  };

  home.file.".config/rofi" = {
    source = "${inputs.dotfiles}/rofi";
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
  home.file.".config/kitty" = {
    source = "${inputs.dotfiles}/kitty";
    recursive = true;
  };
}

