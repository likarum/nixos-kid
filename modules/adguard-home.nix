{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kidFriendly.adguardHome;
in
{
  options.kidFriendly.adguardHome = {
    enable = mkEnableOption "AdGuard Home DNS filtering";

    adminPasswordHash = mkOption {
      type = types.str;
      default = "";
      description = ''
        Hash bcrypt du mot de passe admin.
        Si vide, utilise config.sops.secrets.adguard-admin-password.path
        Générer avec : htpasswd -B -n -b admin VotreMotDePasse
        Ou avec : echo -n "VotreMotDePasse" | mkpasswd -m bcrypt -s
      '';
    };

    extraUserRules = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra AdGuard Home user rules to add (for blocking services, custom rules, etc.)";
      example = [ "||facebook.com^" "@@||allowed-site.com^" ];
    };
  };

  config = mkIf cfg.enable {
    # Lire le hash depuis sops si adminPasswordHash est vide
    assertions = [{
      assertion = cfg.adminPasswordHash != "" || config.sops.secrets ? "adguard-admin-password";
      message = "kidFriendly.adguardHome.adminPasswordHash must be set or sops secret adguard-admin-password must exist";
    }];

    services.adguardhome = {
      enable = true;
      mutableSettings = false;
      host = "0.0.0.0";
      port = 3000;

      settings = {
        users = [
          {
            name = "admin";
            password = if cfg.adminPasswordHash != ""
                      then cfg.adminPasswordHash
                      else builtins.readFile config.sops.secrets."adguard-admin-password".path;
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

        statistics = {
          enabled = true;
          interval = "24h";
        };

        querylog = {
          enabled = true;
          interval = "72h";
          size_memory = 1000;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 3000 ];
  };
}
