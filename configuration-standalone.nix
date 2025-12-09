# Configuration NixOS Kid-Friendly STANDALONE
# Sans flakes - À utiliser directement comme configuration.nix ou à importer
#
# Usage:
#   1. Copiez ce fichier dans /etc/nixos/
#   2. Copiez le dossier modules/ dans /etc/nixos/
#   3. Ajoutez dans votre configuration.nix:
#      imports = [ ./configuration-standalone.nix ];
#   OU remplacez directement votre configuration.nix par ce fichier

{ config, lib, pkgs, ... }:

{
  # Import des modules (chemin relatif)
  imports = [
    # Ajoutez ici votre hardware-configuration.nix si vous utilisez ce fichier comme configuration principale
    # ./hardware-configuration.nix

    # Modules kid-friendly
    ./modules/kid-friendly.nix
  ];

  # ============================================================================
  # CONFIGURATION KID-FRIENDLY
  # ============================================================================

  kid-friendly = {
    enable = true;

    # Informations de l'enfant
    username = "enfant";           # MODIFIEZ selon vos besoins
    fullName = "Mon Enfant";       # MODIFIEZ selon vos besoins

    # Connexion automatique au démarrage
    autoLogin = true;

    # Environnement de bureau (gnome, plasma, ou xfce)
    desktopEnvironment = "gnome";

    # Applications éducatives
    education = {
      enable = true;
      gcompris = true;      # Suite éducative complète - FORTEMENT RECOMMANDÉ
      tuxpaint = true;      # Dessin pour enfants
      childsplay = true;    # Jeux éducatifs
      tuxtyping = true;     # Apprentissage du clavier
      kturtle = true;       # Programmation pour enfants
      gbrainy = true;       # Jeux de logique
      pysiogame = true;     # Activités éducatives
      tuxmath = true;       # Mathématiques
    };

    # Jeux
    games = {
      enable = true;
      supertux = true;        # Plateforme 2D
      supertuxkart = true;    # Course de kart 3D
      frozenBubble = true;    # Puzzle de bulles
      extremetuxracer = true; # Course de pingouin
      minetest = true;        # Type Minecraft
      pysol = true;           # Jeux de cartes
      aisleriot = true;       # Jeux de cartes GNOME
      gnome2048 = true;       # Puzzle 2048
      quadrapassel = true;    # Tetris
      swell-foop = true;      # Puzzle coloré
      hitori = true;          # Puzzle logique
    };

    # Contrôles parentaux
    parental = {
      enable = true;

      # Bloquer le contenu adulte via DNS
      blockAdultContent = true;

      # Empêcher l'accès root
      disableRoot = true;

      # Navigateur sécurisé avec Qwant Junior
      safeBrowser = true;

      # Limite de temps d'écran quotidien (optionnel, décommentez pour activer)
      # screenTimeLimit = "2h";  # 2 heures par jour

      # Plages horaires interdites (optionnel, décommentez pour activer)
      # restrictedHours = [
      #   "20:00-08:00"  # Pas d'écran entre 20h et 8h
      #   # "12:00-14:00"  # Pause déjeuner
      # ];

      # Activer les restrictions horaires
      # timeRestrictions = true;
    };
  };

  # ============================================================================
  # CONFIGURATION SYSTÈME DE BASE (si vous utilisez ce fichier comme config principale)
  # ============================================================================

  # Bootloader (exemple, adaptez selon votre hardware)
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # Réseau
  networking = {
    hostName = "ordinateur-enfant";  # MODIFIEZ selon vos besoins
    networkmanager.enable = true;
  };

  # Fuseau horaire français
  time.timeZone = "Europe/Paris";

  # Packages système supplémentaires (optionnel)
  environment.systemPackages = with pkgs; [
    # Ajoutez ici d'autres packages si nécessaire
    vim
    wget
    git
  ];

  # Créer un compte administrateur pour les parents (optionnel mais recommandé)
  users.users.parent = {
    isNormalUser = true;
    description = "Compte Parent";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    # Définissez le mot de passe avec: sudo passwd parent
  };

  # Activer sudo pour les membres du groupe wheel
  security.sudo.wheelNeedsPassword = true;

  # Version de NixOS (NE PAS MODIFIER après la première installation)
  system.stateVersion = "24.11"; # ADAPTEZ selon votre version actuelle
}
