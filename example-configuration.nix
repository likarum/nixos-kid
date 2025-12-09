# Exemple de configuration pour intégrer nixos-kid dans votre système

{ config, pkgs, ... }:

{
  imports = [
    # Vos autres imports...
    # ./hardware-configuration.nix
    # etc.
  ];

  # Activation de la configuration kid-friendly
  kid-friendly = {
    enable = true;

    # Nom d'utilisateur et informations de l'enfant
    username = "mon-enfant";
    fullName = "Mon Enfant";

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

      # Steam (optionnel) - NÉCESSITE SUPERVISION PARENTALE
      # Activez Family View dans Steam après installation !
      # steam = true;
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

      # Limite de temps d'écran quotidien (optionnel)
      screenTimeLimit = "2h";  # 2 heures par jour

      # Plages horaires interdites (optionnel)
      restrictedHours = [
        "20:00-08:00"  # Pas d'écran entre 20h et 8h
        # "12:00-14:00"  # Pause déjeuner (optionnel)
      ];

      # Activer les restrictions horaires
      timeRestrictions = true;
    };
  };

  # Configuration réseau (adaptez selon vos besoins)
  networking = {
    hostName = "ordinateur-enfant";
    networkmanager.enable = true;
  };

  # Fuseau horaire français
  time.timeZone = "Europe/Paris";

  # Version de NixOS
  system.stateVersion = "24.11"; # Adaptez selon votre version
}
