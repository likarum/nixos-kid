{ config, lib, pkgs, ... }:

let
  cfg = config.kidFriendly.adguardHome;
in
{
  options.kidFriendly.adguardHome = {
    enable = lib.mkEnableOption "AdGuard Home DNS filtering";

    extraUserRules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra AdGuard Home user rules to add (for blocking services, custom rules, etc.)";
      example = [ "||facebook.com^" "@@||allowed-site.com^" ];
    };

    blockedServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of blocked service IDs (uses AdGuard Home's native blocked_services feature)";
      example = [ "facebook" "instagram" "youtube" ];
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional AdGuard Home settings to merge with the default configuration";
      example = { dns.cache_size = 8388608; };
    };
  };

  config = lib.mkIf cfg.enable {
    # SOPS is mandatory - ensure it's enabled and secret exists
    assertions = [
      {
        assertion = config.kidFriendly.sops.enable;
        message = "kidFriendly.sops.enable must be true when using adguardHome";
      }
      {
        assertion = config.sops.secrets ? "adguard-admin-password";
        message = "SOPS secret 'adguard-admin-password' must exist in secrets.yaml";
      }
    ];

    services.adguardhome = {
      enable = true;
      mutableSettings = false;
      host = "0.0.0.0";
      port = 3000;

      settings = lib.recursiveUpdate {
        users = [
          {
            name = "admin";
            # Placeholder - will be replaced by preStart script
            password = "$2a$10$PLACEHOLDER";
          }
        ];

        dns = {
          bind_hosts = [ "127.0.0.1" ];
          port = 53;

          upstream_dns = [
            "https://dns.adguard-dns.com/dns-query"
            "https://dns0.eu/"
            "https://dns.mullvad.net/dns-query"
          ];

          bootstrap_dns = [
            "94.140.14.14"
            "193.110.81.0"
          ];

          protection_enabled = true;
          blocking_mode = "default";
          blocked_response_ttl = 10;

          cache_size = 4194304;
          cache_ttl_min = 0;
          cache_ttl_max = 0;
          cache_optimistic = false;

          enable_dnssec = true;
        };

        filtering = {
          protection_enabled = true;
          filtering_enabled = true;

          parental_enabled = true;
          parental_sensitivity = 13;

          safe_search = {
            enabled = true;
            bing = true;
            duckduckgo = true;
            google = true;
            pixabay = true;
            yandex = true;
            youtube = true;
          };

          safebrowsing_enabled = true;

          blocked_services = {
            ids = cfg.blockedServices;
            schedule = {
              time_zone = "Local";
            };
          };
        };

        filters = [
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            name = "AdGuard DNS filter";
            id = 1;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
            name = "AdAway Default Blocklist";
            id = 2;
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
            name = "StevenBlack Unified hosts";
            id = 3;
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts";
            name = "StevenBlack Fakenews + Gambling + Porn";
            id = 4;
          }
          {
            enabled = true;
            url = "https://blocklistproject.github.io/Lists/porn.txt";
            name = "BlockList Project - Porn";
            id = 5;
          }
          {
            enabled = true;
            url = "https://blocklistproject.github.io/Lists/gambling.txt";
            name = "BlockList Project - Gambling";
            id = 6;
          }
          {
            enabled = true;
            url = "https://blocklistproject.github.io/Lists/redirect.txt";
            name = "BlockList Project - Redirect";
            id = 7;
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro-onlydomains.txt";
            name = "HaGeZi Pro Blocklist";
            id = 8;
          }
        ];

        user_rules = [
          # Cloudflare DoH
          "||cloudflare-dns.com^"
          "||1dot1dot1dot1.cloudflare-dns.com^"
          "||mozilla.cloudflare-dns.com^"
          "||security.cloudflare-dns.com^"
          "||family.cloudflare-dns.com^"

          # Google DoH
          "||dns.google^"
          "||dns.google.com^"
          "||8888.google^"

          # Quad9 DoH
          "||dns.quad9.net^"
          "||dns9.quad9.net^"
          "||dns10.quad9.net^"
          "||dns11.quad9.net^"

          # OpenDNS DoH
          "||doh.opendns.com^"
          "||doh.familyshield.opendns.com^"

          # NextDNS
          "||dns.nextdns.io^"

          # CleanBrowsing
          "||doh.cleanbrowsing.org^"

          # Autres providers DoH
          "||doh.dns.sb^"
          "||doh.pub^"
          "||dns.alidns.com^"
          "||doh.360.cn^"
          "||dot.pub^"
          "||dns.rubyfish.cn^"
          "||doh.centraleu.pi-dns.com^"
          "||dns-nyc.aaflalo.me^"
          "||doh.appliedprivacy.net^"
          "||doh.dnslify.com^"
        ] ++ cfg.extraUserRules;

        log = {
          file = "";
          max_backups = 0;
          max_size = 100;
          max_age = 3;
          compress = false;
          local_time = false;
          verbose = false;
        };

        statistics = {
          enabled = true;
          interval = "24h";
        };

        querylog = {
          enabled = true;
          interval = "72h";
          size_memory = 1000;
        };
      }
      # Allow other modules to override/extend settings (deep merge)
      cfg.settings;
    };

    # Force config regeneration and inject SOPS password
    systemd.services.adguardhome = {
      wants = [ "sops-nix.service" ];
      after = [ "sops-nix.service" ];

      preStart = lib.mkBefore ''
        # Force regeneration by removing old config file
        rm -f /var/lib/AdGuardHome/AdGuardHome.yaml
      '';

      serviceConfig.ExecStartPre = lib.mkAfter [
        # This runs AFTER NixOS generates the config file, but BEFORE adguardhome starts
        "+${pkgs.writeShellScript "adguardhome-inject-password" ''
          set -eu
          CONFIG_FILE="/var/lib/AdGuardHome/AdGuardHome.yaml"

          # Wait for the file to be generated by preStart
          for i in {1..20}; do
            if [ -f "$CONFIG_FILE" ]; then
              break
            fi
            sleep 0.5
          done

          if [ ! -f "$CONFIG_FILE" ]; then
            echo "ERROR: AdGuardHome.yaml not found after waiting"
            exit 1
          fi

          # Inject the password
          ${pkgs.gnused}/bin/sed -i \
            "s|\$2a\$10\$PLACEHOLDER|$(cat ${config.sops.secrets.adguard-admin-password.path})|g" \
            "$CONFIG_FILE"

          echo "Password injected successfully"
        ''}"
      ];
    };

    networking.firewall.allowedTCPPorts = [ 3000 ];
  };
}
