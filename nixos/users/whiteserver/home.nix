# nixos/users/whiteserver/home.nix

  imports = [
    (import ../../../templates/base-home.nix { inherit inputs; username = "whiteserver"; hostname = "whiteserver"; })
  ];
}
