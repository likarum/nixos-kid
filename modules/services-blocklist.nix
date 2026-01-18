{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kidFriendly.servicesBlocklist;

  # Liste des services à bloquer (modifiable via options)
  servicesRules = {
    # Réseaux sociaux
    facebook = [ "||facebook.com^" "||fb.com^" "||fbcdn.net^" "||instagram.com^" "||cdninstagram.com^" ];
    twitter = [ "||twitter.com^" "||x.com^" "||t.co^" "||twimg.com^" ];
    tiktok = [ "||tiktok.com^" "||tiktokcdn.com^" "||musical.ly^" ];
    snapchat = [ "||snapchat.com^" "||sc-cdn.net^" ];
    reddit = [ "||reddit.com^" "||redd.it^" "||redditstatic.com^" ];
    discord = [ "||discord.com^" "||discordapp.com^" "||discord.gg^" ];

    # Gaming platforms (sauf Steam qui est désactivé par défaut)
    epicgames = [ "||epicgames.com^" "||unrealengine.com^" ];
    riotgames = [ "||riotgames.com^" "||leagueoflegends.com^" "||valorant.com^" ];
    blizzard = [ "||blizzard.com^" "||battle.net^" ];
    ea = [ "||ea.com^" "||origin.com^" ];
    ubisoft = [ "||ubisoft.com^" "||ubi.com^" ];
    gog = [ "||gog.com^" ];

    # Streaming
    twitch = [ "||twitch.tv^" "||ttvnw.net^" ];
    youtube = [ "||youtube.com^" "||youtu.be^" "||ytimg.com^" "||googlevideo.com^" ];
    netflix = [ "||netflix.com^" "||nflxvideo.net^" ];

    # Autres
    fortnite = [ "||fortnite.com^" "||fn.gg^" ];
    roblox = [ "||roblox.com^" "||rbxcdn.com^" ];
    minecraft-unofficial = [ "||hypixel.net^" "||mineplex.com^" ];
  };
in
{
  options.kidFriendly.servicesBlocklist = {
    enable = mkEnableOption "Block popular services (gaming, social media, etc.)";

    blockFacebook = mkOption {
      type = types.bool;
      default = true;
      description = "Block Facebook and Instagram";
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

      # Ajouter les règles de blocage selon la configuration
      extraUserRules =
        (optionals cfg.blockFacebook servicesRules.facebook) ++
        (optionals cfg.blockTwitter servicesRules.twitter) ++
        (optionals cfg.blockTikTok servicesRules.tiktok) ++
        (optionals cfg.blockSnapchat servicesRules.snapchat) ++
        (optionals cfg.blockReddit servicesRules.reddit) ++
        (optionals cfg.blockDiscord servicesRules.discord) ++
        (optionals cfg.blockEpicGames servicesRules.epicgames) ++
        (optionals cfg.blockRiotGames servicesRules.riotgames) ++
        (optionals cfg.blockBlizzard servicesRules.blizzard) ++
        (optionals cfg.blockEA servicesRules.ea) ++
        (optionals cfg.blockUbisoft servicesRules.ubisoft) ++
        (optionals cfg.blockGOG servicesRules.gog) ++
        (optionals cfg.blockTwitch servicesRules.twitch) ++
        (optionals cfg.blockYouTube servicesRules.youtube) ++
        (optionals cfg.blockNetflix servicesRules.netflix) ++
        (optionals cfg.blockFortnite servicesRules.fortnite) ++
        (optionals cfg.blockRoblox servicesRules.roblox) ++
        (optionals cfg.blockMinecraftUnofficial servicesRules.minecraft-unofficial) ++
        # Steam est explicitement autorisé (pas de règles ajoutées sauf si blockSteam = true)
        (optionals cfg.blockSteam [ "||steampowered.com^" "||steamcommunity.com^" "||steamstatic.com^" ]) ++
        cfg.customRules;
    };

    warnings =
      let
        blockedServices =
          (optional cfg.blockFacebook "Facebook/Instagram") ++
          (optional cfg.blockTwitter "Twitter/X") ++
          (optional cfg.blockTikTok "TikTok") ++
          (optional cfg.blockSnapchat "Snapchat") ++
          (optional cfg.blockReddit "Reddit") ++
          (optional cfg.blockDiscord "Discord") ++
          (optional cfg.blockEpicGames "Epic Games") ++
          (optional cfg.blockRiotGames "Riot Games") ++
          (optional cfg.blockBlizzard "Blizzard") ++
          (optional cfg.blockEA "EA") ++
          (optional cfg.blockUbisoft "Ubisoft") ++
          (optional cfg.blockGOG "GOG") ++
          (optional cfg.blockTwitch "Twitch") ++
          (optional cfg.blockYouTube "YouTube") ++
          (optional cfg.blockNetflix "Netflix") ++
          (optional cfg.blockFortnite "Fortnite") ++
          (optional cfg.blockRoblox "Roblox") ++
          (optional cfg.blockMinecraftUnofficial "Minecraft unofficial servers") ++
          (optional cfg.blockSteam "Steam (ENABLED - Steam will be blocked!)");

        allowedServices =
          (optional (!cfg.blockSteam) "Steam");
      in
      optional (length blockedServices > 0)
        "kidFriendly.servicesBlocklist: Blocking ${toString (length blockedServices)} services. ${optionalString (length allowedServices > 0) "Allowed: ${concatStringsSep ", " allowedServices}"}";
  };
}
