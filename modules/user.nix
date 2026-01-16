{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kidFriendly.user;
in
{
  options.kidFriendly.user = {
    enable = mkEnableOption "Crée l'utilisateur enfant avec restrictions";

    username = mkOption {
      type = types.str;
      default = "enfant";
      description = "Nom de l'utilisateur enfant";
    };

    fullName = mkOption {
      type = types.str;
      default = "Enfant";
      description = "Nom complet de l'utilisateur";
    };

    initialPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Mot de passe initial (à changer au premier login).
        Si null, le compte est désactivé jusqu'à définition du mot de passe.
      '';
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ "networkmanager" "video" "audio" ];
      description = "Groupes supplémentaires (PAS wheel = pas de sudo)";
    };

    shell = mkOption {
      type = types.package;
      default = pkgs.bash;
      description = "Shell par défaut";
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        firefox
        chromium
        kate
        libreoffice
        vlc
        gnome.file-roller
      ];
      description = "Paquets installés pour l'utilisateur";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.username} = {
      isNormalUser = true;
      description = cfg.fullName;
      extraGroups = cfg.extraGroups;
      shell = cfg.shell;
      packages = cfg.packages;

      initialPassword = if cfg.initialPassword != null
        then cfg.initialPassword
        else null;

      createHome = true;
      home = "/home/${cfg.username}";
    };

    security.sudo.enable = true;
    security.sudo.wheelNeedsPassword = true;

    environment.etc."polkit-1/rules.d/50-restrict-network.rules".text = ''
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("org.freedesktop.NetworkManager") == 0 &&
            subject.user == "${cfg.username}") {
          return polkit.Result.NO;
        }
      });
    '';

    environment.etc."polkit-1/rules.d/50-restrict-udisks.rules".text = ''
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("org.freedesktop.udisks2") == 0 &&
            subject.user == "${cfg.username}") {
          return polkit.Result.NO;
        }
      });
    '';

    environment.etc."polkit-1/rules.d/50-restrict-systemd.rules".text = ''
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("org.freedesktop.systemd1") == 0 &&
            subject.user == "${cfg.username}") {
          return polkit.Result.NO;
        }
      });
    '';

    security.pam.loginLimits = [
      {
        domain = cfg.username;
        type = "hard";
        item = "nproc";
        value = "100";
      }
      {
        domain = cfg.username;
        type = "hard";
        item = "nofile";
        value = "1024";
      }
    ];

    systemd.tmpfiles.rules = [
      "d /home/${cfg.username}/Documents 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/Downloads 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/Pictures 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/Videos 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/Music 0755 ${cfg.username} users -"
    ];
  };
}
