# Guide de Dépannage

Ce document vous aide à résoudre les problèmes courants avec la configuration NixOS Kid-Friendly.

## Installation

### Erreur: "flake.lock not found"
**Solution**: Créez le lock file
```bash
nix flake lock
```

### Erreur: "cannot find module"
**Solution**: Vérifiez que tous les fichiers sont présents dans `modules/`
```bash
ls -la modules/
# Devrait montrer: kid-friendly.nix, education.nix, games.nix, parental.nix
```

### Erreur de build d'un package
**Solution**: Certains packages peuvent ne pas être disponibles sur toutes les architectures
```nix
# Dans votre configuration, désactivez le package problématique:
kid-friendly.games.problematic-game = false;
```

## Langue et Clavier

### L'interface n'est pas en français
**Solution 1**: Vérifier la configuration locale
```bash
localectl status
# Devrait montrer: System Locale: LANG=fr_FR.UTF-8
```

**Solution 2**: Forcer la langue dans la session
```bash
# Ajouter dans ~/.profile ou ~/.bashrc
export LANG=fr_FR.UTF-8
export LANGUAGE=fr_FR:fr
```

### Le clavier est en QWERTY au lieu de AZERTY
**Solution**: Vérifier la configuration X11
```bash
setxkbmap -query
# Devrait montrer: layout: fr
```

Si ce n'est pas le cas:
```bash
setxkbmap fr
```

Pour rendre permanent, vérifiez dans votre configuration:
```nix
services.xserver.xkb.layout = "fr";
```

## Applications

### GCompris ne se lance pas
**Solution 1**: Vérifier l'installation
```bash
which gcompris-qt
```

**Solution 2**: Lancer depuis le terminal pour voir les erreurs
```bash
gcompris-qt
```

**Solution 3**: Problème de droits OpenGL
```bash
# Vérifier que l'accélération matérielle fonctionne
glxinfo | grep "direct rendering"
# Devrait afficher: direct rendering: Yes
```

### Les jeux 3D sont lents ou ne fonctionnent pas
**Solution**: Installer les pilotes graphiques appropriés

Pour NVIDIA:
```nix
services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia.modesetting.enable = true;
```

Pour AMD:
```nix
services.xserver.videoDrivers = [ "amdgpu" ];
```

Pour Intel:
```nix
services.xserver.videoDrivers = [ "modesetting" ];
hardware.graphics.extraPackages = with pkgs; [
  intel-media-driver
  vaapiIntel
];
```

### Pas de son
**Solution 1**: Vérifier que PipeWire fonctionne
```bash
systemctl --user status pipewire
```

**Solution 2**: Tester le son
```bash
speaker-test -t wav -c 2
```

**Solution 3**: Vérifier le volume
```bash
alsamixer
# Appuyez sur M pour unmute si nécessaire
```

## Contrôles Parentaux

### Le DNS filtré ne fonctionne pas
**Solution 1**: Vérifier les serveurs DNS configurés
```bash
cat /etc/resolv.conf
# Devrait contenir:
# nameserver 208.67.222.123
# nameserver 208.67.220.123
```

**Solution 2**: Tester le filtrage
```bash
# Ce site devrait être bloqué:
ping adult-site.com
# Devrait timeout ou répondre avec une IP de blocage
```

**Solution 3**: NetworkManager peut écraser les DNS
```nix
networking.networkmanager.dns = "none";
```

### Les restrictions horaires ne fonctionnent pas
**Solution 1**: Vérifier pam_time
```bash
cat /etc/security/time.conf
```

**Solution 2**: Vérifier que pam_time est chargé
```bash
grep pam_time /etc/pam.d/login
```

**Solution 3**: Tester manuellement
```bash
# En tant que root, essayer de se connecter en tant qu'enfant
su - enfant
```

### La limite de temps d'écran ne fonctionne pas
**Solution 1**: Vérifier le service
```bash
systemctl status screen-time-monitor
```

**Solution 2**: Voir les logs
```bash
journalctl -u screen-time-monitor -f
```

**Solution 3**: Vérifier le fichier de log
```bash
cat /var/log/screen-time-enfant.log
```

## Connexion Automatique

### La connexion automatique ne fonctionne pas
**Solution 1**: Pour GDM (GNOME)
```nix
services.xserver.displayManager.gdm.enable = true;
services.xserver.displayManager.autoLogin = {
  enable = true;
  user = "enfant";
};
```

**Solution 2**: Pour SDDM (KDE Plasma)
```nix
services.displayManager.sddm.enable = true;
services.displayManager.autoLogin = {
  enable = true;
  user = "enfant";
};
```

**Solution 3**: Workaround pour GNOME
```nix
systemd.services."getty@tty1".enable = false;
systemd.services."autovt@tty1".enable = false;
```

## Compte Utilisateur

### L'enfant ne peut pas se connecter
**Solution 1**: Vérifier que le compte existe
```bash
id enfant
```

**Solution 2**: Réinitialiser le mot de passe
```bash
sudo passwd enfant
```

**Solution 3**: Vérifier les droits du dossier home
```bash
ls -la /home/
# Le dossier enfant devrait appartenir à enfant:users
```

### L'enfant peut utiliser sudo
**Solution**: Vérifier la configuration sudo
```bash
sudo -l -U enfant
# Ne devrait rien afficher ou afficher un refus
```

Si ce n'est pas le cas:
```nix
kid-friendly.parental.disableRoot = true;
```

## Performance

### Le système est lent au démarrage
**Solution 1**: Désactiver les applications non utilisées
```nix
kid-friendly.education.geogebra = false;
kid-friendly.games.minetest = false;
```

**Solution 2**: Optimiser le boot
```nix
systemd.services.NetworkManager-wait-online.enable = false;
```

**Solution 3**: Voir les services lents
```bash
systemd-analyze blame
```

### Les applications sont lentes
**Solution 1**: Vérifier la RAM disponible
```bash
free -h
```

**Solution 2**: Vérifier l'utilisation CPU
```bash
htop
```

**Solution 3**: Augmenter le swap si nécessaire
```nix
swapDevices = [ { device = "/swapfile"; size = 4096; } ];
```

## Mises à Jour

### Erreur lors de nixos-rebuild
**Solution 1**: Mettre à jour le flake
```bash
nix flake update
```

**Solution 2**: Nettoyer le cache
```bash
nix-collect-garbage -d
```

**Solution 3**: Voir les erreurs détaillées
```bash
sudo nixos-rebuild switch --show-trace
```

## Désinstallation

### Retirer la configuration kid-friendly
**Solution 1**: Commenter dans flake.nix
```nix
# nixos-kid.nixosModules.kid-friendly
```

**Solution 2**: Désactiver dans configuration.nix
```nix
kid-friendly.enable = false;
```

**Solution 3**: Rebuild sans le module
```bash
sudo nixos-rebuild switch
```

## Logs et Débogage

### Voir les logs système
```bash
# Tous les logs
journalctl -xe

# Logs d'un service spécifique
journalctl -u display-manager -f

# Logs d'une application
journalctl | grep gcompris
```

### Tester la configuration avant rebuild
```bash
sudo nixos-rebuild test
# Si ça fonctionne, faire:
sudo nixos-rebuild switch
```

### Revenir à une version précédente
```bash
# Lister les générations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Revenir à une génération
sudo nixos-rebuild switch --rollback
```

## Support

Si vous ne trouvez pas de solution ici:

1. **Vérifier les issues GitHub**: Consultez les issues existantes
2. **Forum NixOS**: https://discourse.nixos.org/
3. **Documentation NixOS**: https://nixos.org/manual/nixos/stable/
4. **Canal IRC/Matrix**: #nixos sur Libera.Chat

## Contribuer

Vous avez trouvé un bug ou une solution ? Contribuez !
- Créez une issue sur GitHub
- Proposez une pull request
- Partagez votre expérience

## Aide pour les Parents

### Comment surveiller l'activité de l'enfant ?

**Historique de navigation**:
```bash
# Firefox
cat /home/enfant/.mozilla/firefox/*.default*/places.sqlite
# Utilisez un outil SQLite pour lire le fichier
```

**Temps passé**:
```bash
# Voir le log de temps d'écran
cat /var/log/screen-time-enfant.log
```

**Dernière connexion**:
```bash
last enfant
```

### Ajouter des restrictions supplémentaires

Créez un fichier `/etc/nixos/kid-extra.nix`:
```nix
{ config, pkgs, ... }:
{
  # Bloquer des sites spécifiques
  networking.extraHosts = ''
    127.0.0.1 youtube.com
    127.0.0.1 www.youtube.com
  '';

  # Désactiver l'installation de packages
  nix.settings.allowed-users = [ "root" ];
}
```

Puis l'importer dans votre configuration.
