{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kid-friendly.games;
in
{
  options.kid-friendly.games = {
    enable = mkEnableOption "Jeux adaptés aux enfants";

    supertux = mkOption {
      type = types.bool;
      default = true;
      description = "SuperTux - Jeu de plateforme 2D (type Super Mario)";
    };

    supertuxkart = mkOption {
      type = types.bool;
      default = true;
      description = "SuperTuxKart - Jeu de course de kart en 3D";
    };

    frozenBubble = mkOption {
      type = types.bool;
      default = true;
      description = "Frozen Bubble - Jeu de puzzle avec des bulles";
    };

    extremetuxracer = mkOption {
      type = types.bool;
      default = true;
      description = "Extreme Tux Racer - Course de pingouin dans la neige";
    };

    minetest = mkOption {
      type = types.bool;
      default = true;
      description = "Minetest - Alternative libre à Minecraft";
    };

    pysol = mkOption {
      type = types.bool;
      default = true;
      description = "PySolFC - Jeux de solitaire";
    };

    pushover = mkOption {
      type = types.bool;
      default = false;
      description = "Pushover - Jeu de puzzle";
    };

    aisleriot = mkOption {
      type = types.bool;
      default = true;
      description = "Aisleriot - Jeux de cartes GNOME";
    };

    gnome2048 = mkOption {
      type = types.bool;
      default = true;
      description = "GNOME 2048 - Puzzle mathématique";
    };

    quadrapassel = mkOption {
      type = types.bool;
      default = true;
      description = "Quadrapassel - Clone de Tetris";
    };

    swell-foop = mkOption {
      type = types.bool;
      default = true;
      description = "Swell Foop - Jeu de puzzle coloré";
    };

    hitori = mkOption {
      type = types.bool;
      default = true;
      description = "Hitori - Puzzle logique japonais";
    };

    steam = mkOption {
      type = types.bool;
      default = false;
      description = "Steam - Plateforme de jeux (bibliothèque de milliers de jeux)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      # SuperTux - Plateforme 2D classique
      (optional cfg.supertux supertux) ++

      # SuperTuxKart - Course de kart 3D
      (optional cfg.supertuxkart supertuxkart) ++

      # Frozen Bubble - Puzzle de bulles
      (optional cfg.frozenBubble frozen-bubble) ++

      # Extreme Tux Racer - Course de pingouin
      (optional cfg.extremetuxracer extremetuxracer) ++

      # Minetest - Type Minecraft
      (optional cfg.minetest minetest) ++

      # PySolFC - Jeux de cartes
      (optional cfg.pysol pysolfc) ++

      # Pushover - Puzzle
      (optional cfg.pushover pushover) ++

      # Jeux GNOME simples et colorés
      (optional cfg.aisleriot aisleriot) ++
      (optional cfg.gnome2048 gnome.gnome-2048) ++
      (optional cfg.quadrapassel gnome.quadrapassel) ++
      (optional cfg.swell-foop gnome.swell-foop) ++
      (optional cfg.hitori gnome.hitori) ++

      # Jeux supplémentaires recommandés
      [
        # Pingus - Type Lemmings
        pingus

        # Neverball - Jeu d'équilibre et d'adresse
        neverball

        # LBreakout2 - Casse-briques
        lbreakout2

        # Bomber Clone - Type Bomberman
        bomberclone
      ];

    # Configuration pour Minetest (si activé)
    environment.etc = mkIf cfg.minetest {
      "minetest/minetest.conf".text = ''
        # Configuration Minetest pour enfants
        language = fr
        enable_damage = false
        creative_mode = true
      '';
    };

    # Support OpenGL pour les jeux 3D (et 32-bit pour Steam si activé)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;  # Nécessaire pour les jeux 3D et Steam
    };

    # Steam
    programs.steam = mkIf cfg.steam {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
    };
  };
}
