# Exemple de flake.nix à placer dans /etc/nixos/flake.nix
# Ce fichier montre comment utiliser le flake nixos-kid

{
  description = "Configuration NixOS laptop enfant";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Importer le flake nixos-kid
    # Option 1: Depuis GitHub (remplacer USERNAME par votre username)
    # nixos-kid.url = "github:USERNAME/nixos-kid";

    # Option 2: Depuis un chemin local
    nixos-kid.url = "path:/etc/nixos/nixos-kid";

    # Option 3: Depuis GitLab ou autre
    # nixos-kid.url = "gitlab:USERNAME/nixos-kid";
  };

  outputs = { self, nixpkgs, nixos-kid }: {
    nixosConfigurations = {
      # Nom de votre machine (à adapter)
      laptop-enfant = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Hardware configuration
          ./hardware-configuration.nix

          # Modules du flake nixos-kid
          nixos-kid.nixosModules.default

          # Votre configuration (qui importe secrets.nix)
          ./configuration.nix
        ];
      };
    };
  };
}
