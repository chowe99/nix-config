# ~/nix-config/secrets/secrets.nix

# Define your public keys as variables
let
  # Your user's public SSH key (e.g., from ~/.ssh/id_rsa.pub or id_ed25519.pub)
  # Replace with your actual public key string
  user_nix_pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoN5+VkZ8dS6M3EttbIvlCN2H6x5kfbAeG6r1NhrGx0gWJCdL7SeoSl82z0mtLX5cSLeJo+U0R7q2QMw5iHJ3QA4E1o0IbwlQPV1bw2jYu49I1O4b3f30XiSBboy0s1mwD2kUDO6sSfaYMFGjcmmYlN+hIc9bilZCcJPhyJfET7W50i2vi6OOC4+cxXYRJlVXeauYqZaWEOOt0pV74h8DXVmitS6LjiOsDHUUNwbanDDHdBhAiWBGcs32dMK8VivzNMOtVxTshWQBNWn8SrSbVrooxgitoqgqEqdTtNbhjbwUf6pb+0qqTSs4uEwCr/BwFIgYjmodLv+mD2JKQy8lkL8JdYHw24Z1m/6lEp3nWtaoD/zRqHiN08hbfiZ8WlSAE+iUZNzXoRxQYC/Ba9/OScgcE6K9BMbd35LsHoDO+Vbc78A57I0OuAnY1ZeEW9Hj1TrswWBdR6jK5iKFSNJZAphkAgo5OkuzTAdJFy2ygckY9LAUuiMsryzKnCGmx+5e9ubVO0pr+tUdq8+7SIY1Vj3c/wMJsA7BNuYy8zCRRt2IRgks0rxxkwT7cjYD28MC2xSdFte2Xxe97l33EMvkFrP0PnHhFTz9ppv5IWNK2n8IXmleFoM7dSvADzU1MmmDKs0TiRuUHSeoLLDBZZM/OqFLjW2IHM5Ui2ZXTFtYDOw== nix@nixos";

  # Your system's public SSH host key (e.g., from /etc/ssh/ssh_host_ed25519_key.pub on the target machine)
  # Replace with your actual public key string
  system_lemur_pro_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpJ1BuihrKPV4yzQjj8ZysS9k4auH8EwmHgBJt0bTbx root@nixos"; # Removed trailing space, ensure it's the exact key

  # Lists of keys for convenience
  users = [ user_nix_pubkey ];
  targetSystems = [ system_lemur_pro_pubkey ];

  # Keys that can decrypt all general secrets
  defaultRecipientKeys = users ++ targetSystems;

in
# This is the attribute set that agenix will read
{
  "gemini-api-key.age".publicKeys = defaultRecipientKeys;

  # Add an entry for the key you are trying to edit/create
  "openai-api-key.age".publicKeys = defaultRecipientKeys; # Or specify different keys if needed

  "anthropic-api-key.age".publicKeys = defaultRecipientKeys;

  # You can add more secrets here, e.g.:
  # "another-secret.age".publicKeys = [ user_nix_pubkey ];
}
