# ~/nix-config/nixos/users/nix/home.nix
{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home.packages = with pkgs; [
    vim git htop zsh
    neofetch btop
    tree home-manager
    docker
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # Use Hyprland and xdg-desktop-portal-hyprland from NixOS module
    package = pkgs.hyprland;
    # portalPackage = null;
    # Load custom configuration
    # This assumes hyprland.conf is in the same directory as home.nix
    extraConfig = builtins.readFile ./hyprland.conf;
    # Optional: If you have issues with systemd services not finding programs
    # systemd.variables = ["--all"];
  };

  # age.secrets = {
  #   "gemini-api-key".file = ./secrets/gemini-api-key.age;
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

  programs.waybar = {
    enable = true;
    style = ''
      ${builtins.readFile ./waybar/style.css}
    '';
    settings = [
      {
        reload_style_on_change = true;
        # margin-top = "4";
        # width = 1820; # Waybar width
        margin = "16";
        # margin-right = "20";
        # margin-left = "20";
        spacing = 4; # Gaps between modules (4px)
        modules-left = [
          "cpu"
          "temperature"
          "memory"
        ];
        modules-center = [
          "mpris"
        ];
        modules-right = [
          "pulseaudio"
          # "network"
          "power-profiles-daemon"
          "backlight"
          "keyboard-state"
          "sway/language"
          "battery"
          "clock"
          "tray"
        ];
        keyboard-state = {
          numlock = true;
          capslock = true;
          format = "{name} {icon}";
          format-icons = {
            locked = "";
            unlocked = "";
          };
        };
        mpris = {
          format-playing = "{status_icon} {title}";
          format-paused = "{status_icon} {title}";
          format-stopped = "Nothing Playing";
          status-icons = {
            paused = " ";
            playing = " ";
          };
          tooltip-format = " ";
          tooltip-format-disconnected = "";
        };

        battery = {
          bat: "BAT2";
          interval: 60;
          states: {
            warning: 30;
            critical: 15;
          },
          format: "{capacity}% {icon}",;
          format-icons: ["", "", "", "", ""];
          max-length: 25;
        };

        tray = {
          # "icon-size": 21,
          spacing = 10;
        };
        clock = {
          # "timezone": "America/New_York",
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
        };
        cpu = {
          format = "  {usage}%";
          tooltip = false;
        };
        memory = {
          format = "  {}%";
        };
        temperature = {
          interval = 1;
          thermal-zone = 2;
          critical-threshold = 80;
          # "format-critical": "{temperatureC}°C {icon}",
          format = "{icon} {temperatureC}°C";
          format-icons = [ "" "" "" ];
        };
        network = {
          # "interface": "wlp2*", // (Optional) To force the use of this interface
          format-wifi = "{icon}";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "⚠ ";
          format-icons = [ "󰤟 " "󰤢 " "󰤥 " "󰤨 " ];
          on-click = "iwgtk";
        };
        pulseaudio = {
          # "scroll-step": 1, // %, can be a float
          format = "{icon} {volume}%";
          format-bluetooth = "{volume}% {icon}";
          format-muted = " ";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ " " " " " " ];
          };
          on-click = "pavucontrol";
        };
      }
    ];
  };

  home.file.".zshrc".text = ''
    export EDITOR=vim
    alias vim=lvim
    alias age=agenix
    eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
  '';
}

