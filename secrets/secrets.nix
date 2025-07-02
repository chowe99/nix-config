# ~/nix-config/secrets/secrets.nix

# Define your public keys as variables
let
  # Your user's public SSH key (e.g., from ~/.ssh/id_rsa.pub or id_ed25519.pub)
  # Replace with your actual public key string
  user_nix_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1hqEovs7CMEm4VlxWbhVOh3dCfqu+Enzhry6HsTOuO nix@nixos";
  user_whiteserver_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOdjw3/8DiU7OBBvbzOSS9yc5PeIbReUizaYpI/Mqn7p whiteserver@whiteserver";
  user_blackserver_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF3Yd+4yNJDCIT1NEUPJeFtWKx80jxRAwxtW2ecR2z7p blackserver@blackserver";
  user_asusserver_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWkbwYgTyhqUgfkPLOzTTHSSy/8qz9VCxmK4lCz1CNK asusserver@asusserver";

  # Your system's public SSH host key (e.g., from /etc/ssh/ssh_host_ed25519_key.pub on the target machine)
  # Replace with your actual public key string
  system_lemur_pro_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOW8vEJXA9kNsUDO18DJhv0sb61dcXX1YRAxg+ouS29b root@nixos"; # Removed trailing space, ensure it's the exact key
  system_whiteserver_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPVr5b8G51gs5C87Fl4ECGa0kk48dXdKMS3BETgu39j root@nixos";
  system_blackserver_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPiUJbzptsPMcVDQz6mM65WF3eXVVUsyWvmgq7C+XyEx root@blackserver";
  system_asusserver_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID4czca78Hi95lmccum6yDxAMAL+4XeacxVc41Tb+zmx root@nixos";

  # Lists of keys for convenience
  users = [ user_nix_pubkey user_whiteserver_pubkey user_blackserver_pubkey user_asusserver_pubkey ];
  targetSystems = [ system_lemur_pro_pubkey system_whiteserver_pubkey system_blackserver_pubkey system_asusserver_pubkey ];

  # Keys that can decrypt all general secrets
  defaultRecipientKeys = users ++ targetSystems;

in
# This is the attribute set that agenix will read
{
  "gemini-api-key.age".publicKeys = defaultRecipientKeys;

  # Add an entry for the key you are trying to edit/create
  "openai-api-key.age".publicKeys = defaultRecipientKeys; # Or specify different keys if needed

  "anthropic-api-key.age".publicKeys = defaultRecipientKeys;

  "k3s-token.age".publicKeys = defaultRecipientKeys;

  # You can add more secrets here, e.g.:
  # "another-secret.age".publicKeys = [ user_nix_pubkey ];
}
