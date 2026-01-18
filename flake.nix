{
  description = "NixOS Kid-Friendly Configuration - Filtrage DNS robuste avec AdGuard Home";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix }: {
    nixosModules = {
      # Module SOPS secrets management
      sops = import ./modules/sops.nix;

      # Module AdGuard Home
      adguard-home = import ./modules/adguard-home.nix;

      # Module DNS enforcement
      dns-enforcement = import ./modules/dns-enforcement.nix;

      # Module browser policies
      browser-policies = import ./modules/browser-policies.nix;

      # Module firewall
      firewall = import ./modules/firewall.nix;

      # Module services blocklist
      services-blocklist = import ./modules/services-blocklist.nix;

      # Module tout-en-un
      default = { config, pkgs, ... }: {
        imports = [
          sops-nix.nixosModules.sops
          self.nixosModules.sops
          self.nixosModules.adguard-home
          self.nixosModules.dns-enforcement
          self.nixosModules.browser-policies
          self.nixosModules.firewall
          self.nixosModules.services-blocklist
        ];
      };
    };
  };
}
