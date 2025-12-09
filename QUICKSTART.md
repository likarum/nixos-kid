# Guide de Démarrage Rapide

Ce guide vous permet de démarrer rapidement avec NixOS Kid-Friendly.

> **⚠️ NixOS n'est pas encore installé sur votre machine ?**
>
> Consultez d'abord le **[Guide d'Installation Complet](INSTALLATION.md)** pour :
> - Installer NixOS depuis zéro
> - Créer votre clé USB bootable
> - Configurer le matériel

Ce guide suppose que **NixOS est déjà installé** et fonctionnel.

## Installation en 5 Minutes

### Option 1 : Script d'Installation Automatique

```bash
# Clonez le repository
git clone https://github.com/VOTRE-REPO/nixos-kid.git
cd nixos-kid

# Lancez le script d'installation (en tant que root)
sudo ./install.sh mon-enfant

# Suivez les instructions affichées
```

### Option 2 : Installation Manuelle

1. **Ajoutez le flake à votre configuration**

   Éditez votre `/etc/nixos/flake.nix` :

   ```nix
   {
     inputs = {
       nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
       nixos-kid.url = "github:VOTRE-REPO/nixos-kid";
       # ou en local:
       # nixos-kid.url = "path:/chemin/vers/nixos-kid";
     };

     outputs = { self, nixpkgs, nixos-kid }: {
       nixosConfigurations.votre-machine = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         modules = [
           ./configuration.nix
           nixos-kid.nixosModules.kid-friendly
         ];
       };
     };
   }
   ```

2. **Activez dans votre configuration**

   Ajoutez dans `/etc/nixos/configuration.nix` :

   ```nix
   {
     kid-friendly = {
       enable = true;
       username = "mon-enfant";
     };
   }
   ```

3. **Reconstruisez le système**

   ```bash
   sudo nixos-rebuild switch --flake .#votre-machine
   ```

## Configuration Minimale

La configuration minimale qui fonctionne :

```nix
{
  kid-friendly = {
    enable = true;
    username = "enfant";
  };
}
```

Cela activera automatiquement :
- Interface en français
- Applications éducatives de base
- Quelques jeux appropriés
- Contrôles parentaux basiques

## Configuration Recommandée

Pour une expérience optimale :

```nix
{
  kid-friendly = {
    enable = true;
    username = "mon-enfant";
    fullName = "Mon Enfant";
    autoLogin = true;
    desktopEnvironment = "gnome";

    education = {
      enable = true;
      gcompris = true;      # ⭐ ESSENTIEL
      tuxpaint = true;
      tuxtyping = true;
      tuxmath = true;
    };

    games = {
      enable = true;
      supertux = true;
      supertuxkart = true;
      frozenBubble = true;
    };

    parental = {
      enable = true;
      blockAdultContent = true;
      safeBrowser = true;
      disableRoot = true;
    };
  };
}
```

## Configurations par Âge

### 3-5 ans (Maternelle)

```nix
{
  kid-friendly = {
    enable = true;
    username = "petit";

    education = {
      gcompris = true;     # Activités simples
      tuxpaint = true;     # Dessin
      childsplay = true;   # Jeux éducatifs simples
    };

    games = {
      frozenBubble = true;
      # Jeux simples uniquement
    };

    parental = {
      enable = true;
      blockAdultContent = true;
      safeBrowser = true;
      screenTimeLimit = "1h";
      restrictedHours = [ "19:00-09:00" ];
    };
  };
}
```

### 6-10 ans (Primaire)

```nix
{
  kid-friendly = {
    enable = true;
    username = "enfant";

    education = {
      gcompris = true;
      tuxpaint = true;
      tuxtyping = true;    # Apprentissage clavier
      tuxmath = true;      # Maths
      childsplay = true;
    };

    games = {
      supertux = true;
      supertuxkart = true;
      frozenBubble = true;
      extremetuxracer = true;
    };

    parental = {
      enable = true;
      blockAdultContent = true;
      safeBrowser = true;
      screenTimeLimit = "2h";
      restrictedHours = [ "20:00-08:00" ];
    };
  };
}
```

### 11-14 ans (Collège)

```nix
{
  kid-friendly = {
    enable = true;
    username = "ado";

    education = {
      kturtle = true;      # Programmation
      gbrainy = true;      # Logique
      # GeoGebra, Stellarium sont inclus par défaut
    };

    games = {
      minetest = true;     # Type Minecraft
      supertuxkart = true;
      # Plus de liberté sur les jeux
    };

    parental = {
      enable = true;
      blockAdultContent = true;
      safeBrowser = true;
      screenTimeLimit = "3h";
      # Moins de restrictions horaires
    };
  };
}
```

## Premiers Pas Après Installation

1. **Changez le mot de passe**
   ```bash
   sudo passwd mon-enfant
   ```

2. **Reconnectez-vous** (ou redémarrez)

3. **Testez les applications principales** :
   - GCompris (activités éducatives)
   - Tux Paint (dessin)
   - SuperTux (jeu de plateforme)
   - Firefox (navigateur avec Qwant Junior)

4. **Personnalisez le bureau**
   - Fond d'écran adapté
   - Favoris dans le dock
   - Taille des icônes

## Vérifications Post-Installation

```bash
# Vérifier que la langue est bien en français
echo $LANG
# Devrait afficher: fr_FR.UTF-8

# Vérifier le clavier
setxkbmap -query
# Devrait afficher: layout: fr

# Vérifier les DNS (si contrôle parental activé)
cat /etc/resolv.conf
# Devrait contenir les DNS OpenDNS FamilyShield

# Tester une application
gcompris-qt
```

## Commandes Utiles

```bash
# Lister les applications installées
nix-env -q

# Mettre à jour le système
sudo nixos-rebuild switch --upgrade

# Voir les logs d'une application
journalctl -f

# Vérifier l'utilisation disque
du -sh /nix/store

# Nettoyer les anciennes générations
sudo nix-collect-garbage -d
```

## Résolution de Problèmes Rapides

### L'interface n'est pas en français
```bash
export LANG=fr_FR.UTF-8
export LANGUAGE=fr_FR:fr
```

### Le clavier est en QWERTY
```bash
setxkbmap fr
```

### Pas de son
```bash
systemctl --user restart pipewire
```

### Application ne se lance pas
```bash
# Lancez depuis le terminal pour voir les erreurs
nom-de-application
```

Pour plus de détails, consultez [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Ressources

- [README.md](README.md) - Documentation complète
- [APPLICATIONS.md](APPLICATIONS.md) - Liste des applications
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Résolution de problèmes
- [CONTRIBUTING.md](CONTRIBUTING.md) - Comment contribuer

## Support

- Issues GitHub : https://github.com/VOTRE-REPO/nixos-kid/issues
- Forum NixOS : https://discourse.nixos.org/

## Astuce Pro

Créez un alias pour rebuild rapide :

```bash
# Dans ~/.bashrc ou ~/.zshrc
alias kid-rebuild='sudo nixos-rebuild switch --flake /etc/nixos#'
```

Puis utilisez simplement :
```bash
kid-rebuild
```

---

Bon amusement et bon apprentissage ! 🎓🎮
