{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kidFriendly.servicesBlocklist;

  # All known AdGuard Home service IDs
  allServices = [
    "4chan" "500px" "9gag" "activision_blizzard" "aliexpress" "amazon"
    "amazon_streaming" "amino" "apple_streaming" "battle_net" "betano"
    "betfair" "betway" "bigo_live" "bilibili" "blaze" "blizzard_entertainment"
    "bluesky" "box" "canais_globo" "chatgpt" "claro" "claude" "cloudflare"
    "clubhouse" "coolapk" "crunchyroll" "dailymotion" "deepseek" "deezer"
    "directvgo" "discord" "discoveryplus" "disneyplus" "douban" "dropbox"
    "ebay" "electronic_arts" "epic_games" "espn" "facebook" "fifa" "flickr"
    "globoplay" "gog" "hbomax" "hulu" "icloud_private_relay" "iheartradio"
    "imgur" "instagram" "iqiyi" "kakaotalk" "kik" "kook" "lazada"
    "leagueoflegends" "line" "linkedin" "lionsgateplus" "looke" "mail_ru"
    "mastodon" "mercado_libre" "minecraft" "nebula" "netflix" "nintendo"
    "nvidia" "odysee" "ok" "olvid" "onlyfans" "origin" "paramountplus"
    "peacock_tv" "pinterest" "playstation" "playstore" "plenty_of_fish"
    "plex" "pluto_tv" "privacy" "qq" "rakuten_viki" "reddit" "riot_games"
    "roblox" "rockstar_games" "samsung_tv_plus" "shein" "shopee" "signal"
    "skype" "slack" "snapchat" "soundcloud" "spotify" "spotify_video"
    "steam" "telegram" "temu" "tidal" "tiktok" "tinder" "tumblr" "twitch"
    "twitter" "ubisoft" "valorant" "viber" "vimeo" "vk" "voot" "wargaming"
    "wechat" "weibo" "whatsapp" "wizz" "xboxlive" "xiaohongshu" "youtube"
    "yy" "zhihu"
  ];

  # Compute blocked services = all services minus allowed ones
  blockedServices = filter (s: !(elem s cfg.allowedServices)) allServices;
in
{
  options.kidFriendly.servicesBlocklist = {
    enable = mkEnableOption "Block all services by default (whitelist mode)";

    allowedServices = mkOption {
      type = types.listOf types.str;
      default = [ "steam" ];
      description = ''
        List of AdGuard Home service IDs to ALLOW.
        All other services are blocked by default.
        See https://github.com/AdguardTeam/AdGuardHome/blob/master/internal/filtering/servicelist.go
        for the full list of service IDs.
      '';
      example = [ "steam" "spotify" "minecraft" "youtube" ];
    };

    blockMinecraftUnofficial = mkOption {
      type = types.bool;
      default = true;
      description = "Block unofficial Minecraft servers (Hypixel, Mineplex)";
    };

    customRules = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Custom AdGuard Home rules to add";
      example = [ "||example.com^" "@@||allowed-site.com^" ];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.all (s: elem s allServices) cfg.allowedServices;
        message = let
          unknown = filter (s: !(elem s allServices)) cfg.allowedServices;
        in "kidFriendly.servicesBlocklist: Unknown service IDs in allowedServices: ${concatStringsSep ", " unknown}. "
           + "Valid IDs: ${concatStringsSep ", " allServices}";
      }
    ];

    kidFriendly.adguardHome = {
      enable = mkDefault true;

      # Block everything except allowed services
      inherit blockedServices;

      # Add custom rules for Minecraft unofficial servers (not in native list)
      extraUserRules =
        (optionals cfg.blockMinecraftUnofficial [
          "||hypixel.net^"
          "||mineplex.com^"
        ]) ++
        cfg.customRules;
    };

    warnings = let
      count = builtins.length blockedServices;
      allowed = if cfg.allowedServices == []
        then "none"
        else concatStringsSep ", " cfg.allowedServices;
    in [
      "kidFriendly.servicesBlocklist: Whitelist mode - blocking ${toString count} services. Allowed: ${allowed}."
    ];
  };
}
