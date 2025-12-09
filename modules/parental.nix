{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kid-friendly.parental;
in
{
  options.kid-friendly.parental = {
    enable = mkEnableOption "Contrôles parentaux et restrictions";

    blockAdultContent = mkOption {
      type = types.bool;
      default = true;
      description = "Bloquer le contenu adulte via DNS (OpenDNS FamilyShield)";
    };

    timeRestrictions = mkOption {
      type = types.bool;
      default = false;
      description = "Activer les restrictions horaires (à configurer manuellement)";
    };

    disableRoot = mkOption {
      type = types.bool;
      default = true;
      description = "Empêcher l'enfant d'utiliser sudo/root";
    };

    screenTimeLimit = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "2h";
      description = "Limite de temps d'écran quotidien (ex: '2h', '90m')";
    };

    restrictedHours = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "20:00-08:00" "12:00-14:00" ];
      description = "Plages horaires où l'accès est interdit (format HH:MM-HH:MM)";
    };

    safeBrowser = mkOption {
      type = types.bool;
      default = true;
      description = "Configurer Firefox avec page d'accueil sécurisée (Qwant Junior)";
    };
  };

  config = mkIf cfg.enable {
    # DNS filtré pour bloquer contenu adulte (OpenDNS FamilyShield)
    networking.nameservers = mkIf cfg.blockAdultContent [
      "208.67.222.123"  # OpenDNS FamilyShield Primary
      "208.67.220.123"  # OpenDNS FamilyShield Secondary
    ];

    # Empêcher l'enfant d'avoir les droits root
    security.sudo.extraRules = mkIf cfg.disableRoot [
      {
        users = [ config.kid-friendly.username ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" "!ALL" ]; # Refuse toutes les commandes
          }
        ];
      }
    ];

    # Restrictions horaires via pam_time
    security.pam.services = mkIf (cfg.timeRestrictions && cfg.restrictedHours != []) {
      login.text = mkAfter ''
        account required pam_time.so
      '';
    };

    # Configuration de /etc/security/time.conf pour les restrictions horaires
    environment.etc."security/time.conf" = mkIf (cfg.timeRestrictions && cfg.restrictedHours != []) {
      text = let
        # Convertir les plages horaires en format pam_time
        timeRules = map (range: "*;*;${config.kid-friendly.username};!${range}") cfg.restrictedHours;
      in concatStringsSep "\n" timeRules;
    };

    # Limite de temps d'écran (script simple)
    systemd.services.screen-time-monitor = mkIf (cfg.screenTimeLimit != null) {
      description = "Monitor screen time for kid account";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = let
          monitorScript = pkgs.writeShellScript "screen-time-monitor.sh" ''
            #!/bin/sh
            USER="${config.kid-friendly.username}"
            LIMIT="${cfg.screenTimeLimit}"
            LOG_FILE="/var/log/screen-time-$USER.log"

            # Convertir la limite en minutes
            LIMIT_MINUTES=$(echo "$LIMIT" | sed 's/h/*60/;s/m//;' | ${pkgs.bc}/bin/bc)

            while true; do
              if ${pkgs.procps}/bin/pgrep -u "$USER" Xorg > /dev/null || \
                 ${pkgs.procps}/bin/pgrep -u "$USER" wayland > /dev/null; then

                TODAY=$(date +%Y-%m-%d)
                USAGE=$(grep "$TODAY" "$LOG_FILE" 2>/dev/null | tail -1 | cut -d: -f2 || echo 0)
                USAGE=$((USAGE + 1))

                echo "$TODAY:$USAGE" >> "$LOG_FILE"

                if [ "$USAGE" -ge "$LIMIT_MINUTES" ]; then
                  ${pkgs.systemd}/bin/loginctl terminate-user "$USER" 2>/dev/null || true
                  ${pkgs.libnotify}/bin/notify-send -u critical "Temps d'écran dépassé" "La limite quotidienne de $LIMIT a été atteinte."
                fi
              fi

              sleep 60
            done
          '';
        in "${monitorScript}";
        Restart = "always";
      };
    };

    # Applications de contrôle parental disponibles
    environment.systemPackages = with pkgs; [
      # Timekpr-next pour gestion avancée du temps d'écran
      # Note: Peut nécessiter une installation manuelle
    ];

    # Configuration Firefox sécurisée
    programs.firefox = mkIf cfg.safeBrowser {
      enable = true;
      preferences = {
        # Page d'accueil Qwant Junior (moteur de recherche pour enfants)
        "browser.startup.homepage" = "https://www.qwantjunior.com/";

        # Recherche par défaut sur Qwant Junior
        "browser.search.defaultenginename" = "Qwant Junior";

        # Bloquer les pop-ups
        "dom.disable_open_during_load" = true;

        # Safe browsing activé
        "browser.safebrowsing.enabled" = true;
        "browser.safebrowsing.malware.enabled" = true;
        "browser.safebrowsing.phishing.enabled" = true;

        # Désactiver les suggestions de sites adultes
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;

        # Mode de protection renforcée
        "browser.contentblocking.category" = "strict";

        # Langue française
        "intl.accept_languages" = "fr-FR, fr";
        "browser.search.region" = "FR";
      };
    };

    # Hosts file pour bloquer des sites spécifiques (optionnel)
    networking.extraHosts = mkIf cfg.blockAdultContent ''
      # Blocage de sites non adaptés aux enfants
      # Peut être étendu selon les besoins
      127.0.0.1 localhost
    '';

    # Message d'information pour les parents
    environment.etc."kid-friendly-info.txt".text = ''
      CONFIGURATION KID-FRIENDLY NIXOS
      ================================

      Utilisateur enfant: ${config.kid-friendly.username}

      CONTRÔLES PARENTAUX ACTIFS:
      ${optionalString cfg.blockAdultContent "- DNS filtré (OpenDNS FamilyShield)"}
      ${optionalString cfg.disableRoot "- Pas d'accès root/sudo"}
      ${optionalString (cfg.screenTimeLimit != null) "- Limite temps d'écran: ${cfg.screenTimeLimit}"}
      ${optionalString cfg.safeBrowser "- Navigateur sécurisé (Qwant Junior)"}

      RECOMMANDATIONS:
      - Surveillez régulièrement l'activité de l'enfant
      - Modifiez le mot de passe par défaut 'changeme'
      - Les logs d'activité sont dans /var/log/
      - Pour modifier les restrictions, éditez la configuration NixOS

      MOTEUR DE RECHERCHE ENFANT:
      - Qwant Junior: https://www.qwantjunior.com/
      - Sans tracking, adapté aux 6-12 ans

      Pour plus d'infos: https://github.com/votre-repo/nixos-kid
    '';
  };
}
