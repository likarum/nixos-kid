{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kidFriendly.firewall;

  blockedDoHIPs = [
    # Cloudflare
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"

    # Google
    "8.8.8.8"
    "8.8.4.4"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"

    # Quad9
    "9.9.9.9"
    "149.112.112.112"
    "2620:fe::fe"
    "2620:fe::9"
  ];

  allowedDNSIPs = [
    # AdGuard DNS
    "94.140.14.14"
    "94.140.15.15"
    "2a10:50c0::ad1:ff"
    "2a10:50c0::ad2:ff"

    # DNS0.eu
    "193.110.81.0"
    "185.253.5.0"
    "2a0f:fc80::"
    "2a0f:fc81::"

    # Mullvad DNS
    "194.242.2.2"
    "193.19.108.2"
    "2a07:e340::2"
  ];
in
{
  options.kidFriendly.firewall = {
    enable = mkEnableOption "Configure le firewall pour bloquer les contournements DNS";

    lanSubnet = mkOption {
      type = types.str;
      default = "192.168.0.0/16";
      description = "Subnet LAN autorisé à accéder à l'interface admin AdGuard Home";
    };

    blockDoHProviders = mkOption {
      type = types.bool;
      default = true;
      description = "Bloque les IPs des providers DoH publics (Cloudflare, Google, Quad9)";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      enable = true;

      allowedTCPPorts = [ 3000 ];

      extraCommands = ''
        # Restriction interface admin AdGuard Home au LAN
        iptables -A nixos-fw -p tcp --dport 3000 ! -s ${cfg.lanSubnet} -j nixos-fw-log-refuse
        ip6tables -A nixos-fw -p tcp --dport 3000 ! -s ${cfg.lanSubnet} -j nixos-fw-log-refuse

        # Blocage des serveurs DoH publics (port 443)
        ${optionalString cfg.blockDoHProviders (concatMapStringsSep "\n" (ip:
          if hasInfix ":" ip then
            "ip6tables -A OUTPUT -d ${ip} -p tcp --dport 443 -j REJECT --reject-with icmp6-port-unreachable"
          else
            "iptables -A OUTPUT -d ${ip} -p tcp --dport 443 -j REJECT --reject-with icmp-port-unreachable"
        ) blockedDoHIPs)}

        # Exception: autoriser nos upstreams DNS
        ${concatMapStringsSep "\n" (ip:
          if hasInfix ":" ip then
            "ip6tables -I OUTPUT -d ${ip} -p tcp --dport 443 -j ACCEPT"
          else
            "iptables -I OUTPUT -d ${ip} -p tcp --dport 443 -j ACCEPT"
        ) allowedDNSIPs}

        # Blocage DNS non-local (port 53)
        iptables -A OUTPUT -p udp --dport 53 ! -d 127.0.0.1 -j REJECT --reject-with icmp-port-unreachable
        iptables -A OUTPUT -p tcp --dport 53 ! -d 127.0.0.1 -j REJECT --reject-with icmp-port-unreachable
        ip6tables -A OUTPUT -p udp --dport 53 ! -d ::1 -j REJECT --reject-with icmp6-port-unreachable
        ip6tables -A OUTPUT -p tcp --dport 53 ! -d ::1 -j REJECT --reject-with icmp6-port-unreachable

        # Blocage DoT (port 853)
        iptables -A OUTPUT -p tcp --dport 853 -j REJECT --reject-with icmp-port-unreachable
        ip6tables -A OUTPUT -p tcp --dport 853 -j REJECT --reject-with icmp6-port-unreachable
      '';

      extraStopCommands = ''
        iptables -D OUTPUT -p tcp --dport 853 -j REJECT --reject-with icmp-port-unreachable 2>/dev/null || true
        ip6tables -D OUTPUT -p tcp --dport 853 -j REJECT --reject-with icmp6-port-unreachable 2>/dev/null || true
      '';
    };

    systemd.services.check-firewall-rules = {
      description = "Vérifie que les règles firewall anti-DoH sont actives";
      wantedBy = [ "multi-user.target" ];
      after = [ "firewall.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        echo "Checking firewall rules..."

        ${optionalString cfg.blockDoHProviders ''
          if iptables -L OUTPUT -n | grep -q "REJECT.*443"; then
            echo "DoH providers blocking rules: OK"
          else
            echo "WARNING: DoH blocking rules not found!"
          fi
        ''}

        if iptables -L OUTPUT -n | grep -q "REJECT.*udp dpt:53"; then
          echo "External DNS blocking: OK"
        else
          echo "WARNING: External DNS blocking rules not found!"
        fi

        if iptables -L OUTPUT -n | grep -q "REJECT.*tcp dpt:853"; then
          echo "DoT blocking: OK"
        else
          echo "WARNING: DoT blocking rules not found!"
        fi

        echo "Firewall rules check completed"
      '';
    };
  };
}
