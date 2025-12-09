{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kid-friendly.education;
in
{
  options.kid-friendly.education = {
    enable = mkEnableOption "Applications éducatives";

    gcompris = mkOption {
      type = types.bool;
      default = true;
      description = "GCompris - Suite complète de plus de 100 activités éducatives en français";
    };

    tuxpaint = mkOption {
      type = types.bool;
      default = true;
      description = "Tux Paint - Programme de dessin pour enfants";
    };

    childsplay = mkOption {
      type = types.bool;
      default = true;
      description = "Childsplay - Collection de jeux éducatifs";
    };

    tuxtyping = mkOption {
      type = types.bool;
      default = true;
      description = "Tux Typing - Apprendre à taper au clavier";
    };

    kturtle = mkOption {
      type = types.bool;
      default = true;
      description = "KTurtle - Apprentissage de la programmation";
    };

    gbrainy = mkOption {
      type = types.bool;
      default = true;
      description = "gBrainy - Jeux de logique et mémoire";
    };

    pysiogame = mkOption {
      type = types.bool;
      default = true;
      description = "PySioGame - Collection d'activités éducatives";
    };

    tuxmath = mkOption {
      type = types.bool;
      default = true;
      description = "Tux Math - Apprentissage des mathématiques";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      # GCompris - LA référence des logiciels éducatifs pour enfants
      (optional cfg.gcompris gcompris-qt) ++

      # Tux Paint - Dessin et créativité
      (optional cfg.tuxpaint tuxpaint) ++
      (optional cfg.tuxpaint tuxpaint-stamps) ++

      # Childsplay - Jeux éducatifs variés
      (optional cfg.childsplay childsplay) ++

      # Tux Typing - Apprentissage du clavier
      (optional cfg.tuxtyping tuxtype) ++

      # KTurtle - Programmation pour enfants (Logo)
      (optional cfg.kturtle kturtle) ++

      # gBrainy - Logique, mémoire, calcul mental
      (optional cfg.gbrainy gbrainy) ++

      # PySioGame - Activités éducatives diverses
      (optional cfg.pysiogame pysiogame) ++

      # Tux Math - Mathématiques
      (optional cfg.tuxmath tuxmath) ++

      # Applications supplémentaires recommandées
      [
        # Éditeur de texte enrichi pour les devoirs
        libreoffice-fresh

        # Logiciel de géométrie interactive
        geogebra

        # Stellarium - Planétarium
        stellarium
      ];

    # Configuration de GCompris pour le français
    environment.variables = mkIf cfg.gcompris {
      GCOMPRIS_LANG = "fr_FR";
    };

    # Création d'un dossier pour les créations de l'enfant
    systemd.tmpfiles.rules = [
      "d /home/${config.kid-friendly.username}/Créations 0755 ${config.kid-friendly.username} users -"
      "d /home/${config.kid-friendly.username}/Dessins 0755 ${config.kid-friendly.username} users -"
      "d /home/${config.kid-friendly.username}/Devoirs 0755 ${config.kid-friendly.username} users -"
    ];
  };
}
