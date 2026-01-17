{
  description = "NixOS Kid-Friendly Configuration - Filtrage DNS robuste avec AdGuard Home";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = {
      # Module AdGuard Home
      adguard-home = import ./modules/adguard-home.nix;

      # Module DNS enforcement
      dns-enforcement = import ./modules/dns-enforcement.nix;

      # Module browser policies
      browser-policies = import ./modules/browser-policies.nix;

      # Module firewall
      firewall = import ./modules/firewall.nix;

      # Module tout-en-un
      default = { config, pkgs, ... }: {
        imports = [
          self.nixosModules.adguard-home
          self.nixosModules.dns-enforcement
          self.nixosModules.browser-policies
          self.nixosModules.firewall
        ];
      };
    };
  };
}
