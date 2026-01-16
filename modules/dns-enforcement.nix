{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kidFriendly.dnsEnforcement;
in
{
  options.kidFriendly.dnsEnforcement = {
    enable = mkEnableOption "Force l'utilisation du DNS local (127.0.0.1)";
  };

  config = mkIf cfg.enable {
    networking.nameservers = [ "127.0.0.1" ];
    networking.networkmanager.dns = "none";

    environment.etc."resolv.conf" = {
      text = ''
        # Managed by NixOS - DNS filtering via AdGuard Home
        # DO NOT MODIFY - This file is immutable
        nameserver 127.0.0.1
      '';
      mode = "0444";
    };

    services.resolved.enable = false;
    services.dnsmasq.enable = false;
    services.unbound.enable = false;
    services.bind.enable = false;

    systemd.tmpfiles.rules = [
      "f /etc/resolv.conf 0444 root root - nameserver 127.0.0.1\n"
    ];

    systemd.services.check-dns-enforcement = {
      description = "Vérifie que le DNS est configuré sur localhost";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "adguardhome.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        echo "Checking DNS configuration..."
        if ! grep -q "nameserver 127.0.0.1" /etc/resolv.conf; then
          echo "WARNING: DNS is NOT configured to use localhost!"
          echo "Expected: nameserver 127.0.0.1"
          echo "Current content:"
          cat /etc/resolv.conf
          exit 1
        fi
        echo "DNS configuration OK: using localhost (AdGuard Home)"
      '';
    };
  };
}
