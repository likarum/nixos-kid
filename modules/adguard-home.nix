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
      default = "$2y$10$REPLACE_WITH_ACTUAL_HASH";
      description = ''
        Hash bcrypt du mot de passe admin.
        Générer avec : htpasswd -B -n -b admin VotreMotDePasse
        Ou avec : echo -n "VotreMotDePasse" | mkpasswd -m bcrypt -s
      '';
    };
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      mutableSettings = false;
      host = "0.0.0.0";
      port = 3000;

      settings = {
        users = [
          {
            name = "admin";
            password = cfg.adminPasswordHash;
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
        ];

        statistics = {
          enabled = true;
          interval = 24h;
        };

        querylog = {
          enabled = true;
          interval = 72h;
          size_memory = 1000;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 3000 ];
  };
}
