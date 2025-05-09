
# NixOS Flake-Based Configuration

This repository contains a flake-based configuration for NixOS, including system and user settings managed with Home Manager. Below are the instructions for setting up and using this configuration on a new machine.

## Setting Up on a New Machine

### 0. Run `chmod +x setup_nixos.sh` and run the setup script `./setup_nixos.sh`, or follow the instructions below

### 1. Clone the Flake Repo to the New Machine

   First, clone this repository to your new machine:

   ```bash
   git clone https://github.com/chowe99/nix-config.git
   ```

### 2. Install Nix and Enable Flakes on the New Machine

   Ensure that Nix is installed on the new machine, and that flakes are enabled. In your `/etc/nixos/configuration.nix`, add the following line:

   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

   Then, rebuild your NixOS configuration:

   ```bash
   sudo nixos-rebuild switch
   ```

### 3. Copy Over Host-Specific Configuration (Optional)

   If your configuration contains machine-specific settings (e.g., `hardware-configuration.nix`), you may need to adjust or copy these settings from your old machine to the new one.

### 4. Rebuild the System with the Flake

   On the new machine, navigate to the folder containing the `flake.nix` file and run:

   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

### 5. Set Up Home Manager (if applicable)

   If you're using Home Manager for user-specific configurations (e.g., zsh settings, packages), ensure that it is applied as part of your rebuild. You can also run:

   ```bash
   home-manager switch
   ```

### 6. Back Up Any Machine-Specific Data or Services

   If you're migrating a machine that hosts specific services, ensure that necessary data and services are backed up and restored on the new machine. This may include copying over specific directories or configurations related to services such as databases or web applications.

### 7. Run Additional Customization or Tweaks

   Once the flake-based configuration is applied, you may want to tweak specific settings for the new hardware, network configuration, or other machine-specific parameters.
