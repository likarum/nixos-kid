{
  description = "NixOS Kid-Friendly Configuration - Filtrage DNS robuste avec AdGuard Home";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
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

        # Module tout-en-un (SOPS enabled by default)
        default = { config, lib, pkgs, ... }: {
          imports = [
            sops-nix.nixosModules.sops
            self.nixosModules.sops
            self.nixosModules.adguard-home
            self.nixosModules.dns-enforcement
            self.nixosModules.browser-policies
            self.nixosModules.firewall
            self.nixosModules.services-blocklist
          ];

          # Enable SOPS by default (v2.0 - SOPS is mandatory)
          kidFriendly.sops.enable = lib.mkDefault true;
        };
      };

      # Formatter for `nix fmt`
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );

      # Checks (can be run with `nix flake check`)
      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Simple syntax check - build a minimal config
          build-minimal = (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              self.nixosModules.default
              {
                # Minimal stub configuration
                boot.loader.grub.device = "nodev";
                fileSystems."/" = {
                  device = "/dev/null";
                  fsType = "ext4";
                };
                system.stateVersion = "24.11";

                # Configure nixos-kid with mock secrets
                kidFriendly = {
                  sops.secretsFile = pkgs.writeText "mock-secrets.yaml" "dummy";
                  adguardHome.enable = true;
                  dnsEnforcement.enable = true;
                  firewall.enable = true;
                };
              }
            ];
          }).config.system.build.toplevel;
        }
      );
    };
}
