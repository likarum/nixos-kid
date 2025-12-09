{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kid-friendly;
in
{
  imports = [
    ./education.nix
    ./games.nix
    ./parental.nix
  ];

  options.kid-friendly = {
    enable = mkEnableOption "Configuration kid-friendly complète";

    username = mkOption {
      type = types.str;
      default = "enfant";
      description = "Nom d'utilisateur du compte enfant";
    };

    fullName = mkOption {
      type = types.str;
      default = "Enfant";
      description = "Nom complet de l'enfant";
    };

    autoLogin = mkOption {
      type = types.bool;
      default = true;
      description = "Activer la connexion automatique pour l'enfant";
    };

    desktopEnvironment = mkOption {
      type = types.enum [ "gnome" "plasma" "xfce" ];
      default = "gnome";
      description = "Environnement de bureau à utiliser";
    };
  };

  config = mkIf cfg.enable {
    # Activer les sous-modules par défaut
    kid-friendly.education.enable = mkDefault true;
    kid-friendly.games.enable = mkDefault true;
    kid-friendly.parental.enable = mkDefault true;

    # Configuration de la langue française
    i18n = {
      defaultLocale = "fr_FR.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };
    };

    # Configuration du clavier français
    console.keyMap = "fr";

    # Environnement de bureau
    services.xserver = {
      enable = true;

      # Configuration du clavier
      xkb = {
        layout = "fr";
        variant = "";
      };

      # Display manager et auto-login
      displayManager = mkIf cfg.autoLogin {
        autoLogin = {
          enable = true;
          user = cfg.username;
        };
      };
    } // (if cfg.desktopEnvironment == "gnome" then {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    } else if cfg.desktopEnvironment == "plasma" then {
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    } else {
      displayManager.lightdm.enable = true;
      desktopManager.xfce.enable = true;
    });

    # Configuration GNOME spécifique pour enfants
    services.gnome = mkIf (cfg.desktopEnvironment == "gnome") {
      # Désactiver certaines applications GNOME non nécessaires
      core-utilities.enable = true;
    };

    # Polices adaptées
    fonts = {
      packages = with pkgs; [
        liberation_ttf
        dejavu_fonts
        noto-fonts
        noto-fonts-emoji
        font-awesome
      ];
      fontconfig = {
        defaultFonts = {
          serif = [ "DejaVu Serif" ];
          sansSerif = [ "DejaVu Sans" ];
          monospace = [ "DejaVu Sans Mono" ];
        };
      };
    };

    # Applications de base
    environment.systemPackages = with pkgs; [
      # Navigateur web avec contrôle parental
      firefox

      # Lecteur vidéo simple
      vlc

      # Visionneuse d'images
      eog

      # Éditeur de texte simple
      gnome-text-editor

      # Calculatrice
      gnome-calculator
    ];

    # Son activé
    hardware.pulseaudio.enable = mkDefault false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Support de l'impression (pour imprimer les créations)
    services.printing.enable = true;

    # Création du compte utilisateur enfant
    users.users.${cfg.username} = {
      isNormalUser = true;
      description = cfg.fullName;
      extraGroups = [ "audio" "video" ];
      initialPassword = "changeme"; # À changer au premier démarrage
    };

    # Variables d'environnement pour forcer le français
    environment.variables = {
      LANG = "fr_FR.UTF-8";
      LANGUAGE = "fr_FR:fr";
      LC_ALL = "fr_FR.UTF-8";
    };

    # Configuration Firefox pour enfants
    programs.firefox = {
      enable = true;
      preferences = {
        "intl.accept_languages" = "fr-FR, fr";
        "browser.search.region" = "FR";
        "browser.startup.homepage" = "https://www.qwantjunior.com/";
      };
    };
  };
}
