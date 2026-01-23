{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kidFriendly.servicesBlocklist;
in
{
  options.kidFriendly.servicesBlocklist = {
    enable = mkEnableOption "Block popular services (gaming, social media, etc.)";

    blockFacebook = mkOption {
      type = types.bool;
      default = true;
      description = "Block Facebook";
    };

    blockInstagram = mkOption {
      type = types.bool;
      default = true;
      description = "Block Instagram";
    };

    blockTwitter = mkOption {
      type = types.bool;
      default = true;
      description = "Block Twitter/X";
    };

    blockTikTok = mkOption {
      type = types.bool;
      default = true;
      description = "Block TikTok";
    };

    blockSnapchat = mkOption {
      type = types.bool;
      default = true;
      description = "Block Snapchat";
    };

    blockReddit = mkOption {
      type = types.bool;
      default = true;
      description = "Block Reddit";
    };

    blockDiscord = mkOption {
      type = types.bool;
      default = true;
      description = "Block Discord";
    };

    blockEpicGames = mkOption {
      type = types.bool;
      default = true;
      description = "Block Epic Games Store";
    };

    blockRiotGames = mkOption {
      type = types.bool;
      default = true;
      description = "Block Riot Games (League of Legends, Valorant)";
    };

    blockBlizzard = mkOption {
      type = types.bool;
      default = true;
      description = "Block Blizzard/Battle.net";
    };

    blockEA = mkOption {
      type = types.bool;
      default = true;
      description = "Block EA/Origin";
    };

    blockUbisoft = mkOption {
      type = types.bool;
      default = true;
      description = "Block Ubisoft";
    };

    blockGOG = mkOption {
      type = types.bool;
      default = true;
      description = "Block GOG";
    };

    blockTwitch = mkOption {
      type = types.bool;
      default = true;
      description = "Block Twitch";
    };

    blockYouTube = mkOption {
      type = types.bool;
      default = true;
      description = "Block YouTube";
    };

    blockNetflix = mkOption {
      type = types.bool;
      default = true;
      description = "Block Netflix";
    };

    blockFortnite = mkOption {
      type = types.bool;
      default = true;
      description = "Block Fortnite";
    };

    blockRoblox = mkOption {
      type = types.bool;
      default = true;
      description = "Block Roblox";
    };

    blockMinecraftUnofficial = mkOption {
      type = types.bool;
      default = true;
      description = "Block unofficial Minecraft servers (Hypixel, Mineplex)";
    };

    # Steam est explicitement autorisé par défaut
    blockSteam = mkOption {
      type = types.bool;
      default = false;
      description = "Block Steam (disabled by default as Steam is allowed)";
    };

    customRules = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Custom AdGuard Home rules to add";
      example = [ "||example.com^" "@@||allowed-site.com^" ];
    };
  };

  config = mkIf cfg.enable {
    kidFriendly.adguardHome = {
      enable = mkDefault true;

      # Use AdGuard Home's native blocked_services feature
      # Block all available services using their official IDs
      blockedServices = [
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
        "telegram" "temu" "tidal" "tiktok" "tinder" "tumblr" "twitch" "twitter"
        "ubisoft" "valorant" "viber" "vimeo" "vk" "voot" "wargaming" "wechat"
        "weibo" "whatsapp" "wizz" "xboxlive" "xiaohongshu" "youtube" "yy" "zhihu"
      ];

      # Add custom rules for Minecraft unofficial servers (not in native list)
      extraUserRules =
        (optionals cfg.blockMinecraftUnofficial [
          "||hypixel.net^"
          "||mineplex.com^"
        ]) ++
        cfg.customRules;
    };

    warnings = [
      "kidFriendly.servicesBlocklist: Blocking ALL available services (130+ services) including social media, streaming, gaming, and shopping platforms."
    ];
  };
}
