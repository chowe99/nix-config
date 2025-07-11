# ~/nix-config/templates/user-home.nix
{ config, pkgs, lib, inputs, username, hostname, ... }:

let
zshrc = import ../configs/zshrc.nix { inherit username; };
in
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

  config = lib.mkMerge [
  {
# Set packageSet based on system
    packageSet = if pkgs.system == "aarch64-linux" 
      then inputs.nixpkgs-unstable.legacyPackages.${pkgs.system} 
    else pkgs;

    home.stateVersion = "25.05";
    home.username = username;
    home.homeDirectory = "/home/${username}";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];


    home.packages = with config.packageSet; [
      (pkgs.writeShellScriptBin "cat-files" (builtins.readFile ../scripts/cat-files.sh))
        btop-cuda
        tree
        docker
        signal-desktop
# wineWowPackages.waylandFull
        papirus-icon-theme
# winetricks
        dpkg
        libcanberra
        lsd
        nix-prefetch-git
        oh-my-posh
        waybar
        fastfetch
        superfile
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
    home.sessionVariables = {
      XDG_DATA_DIRS = "${config.home.homeDirectory}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
    };

    home.activation.setupFlatpak = lib.hm.dag.entryAfter ["writeBoundary"] ''
      flatpak_cmd="${config.packageSet.flatpak}/bin/flatpak"

      if ! $flatpak_cmd remotes | grep -q flathub; then
        $flatpak_cmd remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
          fi

          apps=(
              md.obsidian.Obsidian
              com.bitwarden.desktop
              app.zen_browser.zen
              com.github.tchx84.Flatseal
              )

          for app in ''${apps[@]}; do
            if ! $flatpak_cmd list | grep -q $app; then
              $flatpak_cmd install -y --user flathub $app
                fi
                done

# Give Zen Browser access to ~/Downloads with read-write access
                $flatpak_cmd override --user app.zen_browser.zen --filesystem=$HOME/Downloads:rw
                '';


# Example Flatpak desktop entry using cpu_architecture
    xdg.desktopEntries."md.obsidian.Obsidian" = {
      name = "Obsidian";
      exec = "flatpak run --no-sandbox --branch=stable --arch=${config.cpu_architecture} --command=obsidian.sh md.obsidian.Obsidian";
      icon = "md.obsidian.Obsidian";
      type = "Application";
    };

    programs.home-manager.enable = true;

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
        name = "fast-syntax-highlighting";
        src = config.packageSet.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = config.packageSet.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
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
        alias vim=nvim
        '';
      force = true;
    };

# File imports and other settings unchanged
    home.file.".config/rofi".source = "${inputs.dotfiles}/rofi";
    home.file.".config/rofi".recursive = true;
    home.file.".config/waybar".source = "${inputs.dotfiles}/waybar";
    home.file.".config/waybar".recursive = true;
    home.file.".config/hypr".source = "${inputs.dotfiles}/hypr";
    home.file.".config/hypr".recursive = true;
    home.file.".config/kitty".source = "${inputs.dotfiles}/kitty";
    home.file.".config/kitty".recursive = true;
  }
  zshrc
    ];
}
