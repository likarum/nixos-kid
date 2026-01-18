{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kidFriendly.sops;
in
{
  options.kidFriendly.sops = {
    enable = mkEnableOption "SOPS secrets management for nixos-kid";

    secretsFile = mkOption {
      type = types.path;
      default = /etc/nixos/nixos-kid/secrets.yaml;
      description = "Path to the encrypted secrets.yaml file";
    };
  };

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = cfg.secretsFile;
      age.keyFile = "/var/lib/sops-nix/key.txt";

      secrets = {
        # AdGuard Home admin password hash
        adguard-admin-password = {
          owner = "root";
          mode = "0400";
        };

        # Child user initial password
        child-initial-password = {
          owner = "root";
          mode = "0400";
        };

        # Child username
        child-username = {
          owner = "root";
          mode = "0400";
        };

        # Child full name
        child-fullname = {
          owner = "root";
          mode = "0400";
        };
      };
    };
  };
}
