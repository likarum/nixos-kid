{ config, lib, pkgs, ... }:

let
  cfg = config.kidFriendly.sops;
in
{
  options.kidFriendly.sops = {
    enable = lib.mkEnableOption "SOPS secrets management for nixos-kid";

    secretsFile = lib.mkOption {
      type = lib.types.path;
      example = "/etc/nixos/nixos-kid/secrets.yaml";
      description = ''
        Path to the encrypted secrets.yaml file.
        This must be set to your actual secrets.yaml location.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = cfg.secretsFile != null;
      message = "kidFriendly.sops.secretsFile must be set to your secrets.yaml path";
    }];

    sops = {
      defaultSopsFile = cfg.secretsFile;

      # Utilise la clé SSH de l'hôte au lieu d'une clé age dédiée
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

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
