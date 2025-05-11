# ~/nix-config/nixos/users/nix/nix.nix
{ config, pkgs, lib, ... }:

let
  # Helper to safely construct the export line for Gemini API Key
  geminiApiKeyExport =
    if config ? age && config.age ? secrets && config.age.secrets ? "gemini-api-key" && config.age.secrets."gemini-api-key" ? path
    then ''export GEMINI_API_KEY="$(<${config.age.secrets."gemini-api-key".path})"''
    else ""; # Or lib.warn "Gemini API Key path not found" ""

  # Helper for OpenAI API Key
  openaiApiKeyExport =
    if config ? age && config.age ? secrets && config.age.secrets ? "openai-api-key" && config.age.secrets."openai-api-key" ? path
    then ''export OPENAI_API_KEY="$(<${config.age.secrets."openai-api-key".path})"''
    else "";

  # Helper for Anthropic API Key
  anthropicApiKeyExport =
    if config ? age && config.age ? secrets && config.age.secrets ? "anthropic-api-key" && config.age.secrets."anthropic-api-key" ? path
    then ''export ANTHROPIC_API_KEY="$(<${config.age.secrets."anthropic-api-key".path})"''
    else "";

in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    jetbrains-mono
    fira-code

    vim git htop zsh
    neofetch btop
    tree 
    docker
    superfile
  ];


  xdg.desktopEntries."superfile" = {
    name = "Superfile (TUI)";
    genericName = "TUI File Manager";
    comment = "Fast and modern TUI file manager";
    exec = "kitty -e \'zsh -c superfile\;\$SHELL\'"; # Adjust binary name if needed
    icon = "utilities-terminal"; # Or "superfile-fm" if icon provided
    terminal = false; # <<<--- THIS IS THE CRUCIAL CHANGE
    categories = ["Utility" "FileTools" "ConsoleOnly" "System"];
    mimeType = ["inode/directory"];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    # Use Hyprland and xdg-desktop-portal-hyprland from NixOS module
    package = pkgs.hyprland;
    # portalPackage = null;
    # Load custom configuration
    extraConfig = builtins.readFile ./hyprland.conf;
    # Optional: If you have issues with systemd services not finding programs
    # systemd.variables = ["--all"];
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
    initExtra = ''
      # Aliases and other shell settings from your flake
      alias vim=lvim
      alias age=agenix # This will use the agenix from systemPackages
      eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
      alias rebuild="sudo nixos-rebuild switch --flake ~/nix-config#nixos"

      # Export the Gemini API Key
      # The file path comes from the NixOS configuration `config.age.secrets...`
      ${geminiApiKeyExport}
      ${anthropicApiKeyExport}
      ${openaiApiKeyExport}
    '';
  };

  programs.git = {
    enable = true;
    userName = "chowe99";
    userEmail = "chowej99@gmail.com";
  };

}

