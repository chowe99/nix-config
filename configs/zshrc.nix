{ config, pkgs, lib, inputs, username, hostname, ... }:
{
    home.file.".zshrc" = {
      text = ''
        export EDITOR=vim
        alias age=agenix
        eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
        alias rebuild="sudo nixos-rebuild switch --flake ~/nix-config#${username}"
        # alias ssf2='wine "$HOME/.wine/drive_c/Program Files (x86)/Super Smash Flash 2 Beta/SSF2.exe"'
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
        if [[ -f /run/agenix/k3s-token ]]; then
          export K3S_TOKEN=$(cat /run/agenix/k3s-token)
        fi
      '';
      force = true;
    };
}
