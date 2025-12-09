# Installation

Guide concis pour installer NixOS Kid-Friendly de A à Z.

## 1. Installer NixOS

### Si NixOS n'est pas encore installé

Suivez la documentation officielle : **https://nixos.org/manual/nixos/stable/#sec-installation**

**Particularités pour Kid-Friendly** :
- ✅ Activez les **flakes** dans la config initiale
- ✅ Configurez le **clavier français** (AZERTY)
- ✅ Créez un compte **administrateur** (pour vous, le parent)
- ✅ Choisissez **GNOME** comme environnement (plus simple pour enfants)

Configuration minimale à avoir dans `/etc/nixos/configuration.nix` :

```nix
{
  # Activer les flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Clavier français
  console.keyMap = "fr";
  services.xserver.xkb.layout = "fr";

  # Locale française
  i18n.defaultLocale = "fr_FR.UTF-8";
  time.timeZone = "Europe/Paris";

  # GNOME
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Son
  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;
}
```

## 2. Installer Kid-Friendly

### Via Flake (recommandé)

**a) Créer `/etc/nixos/flake.nix` :**

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-kid.url = "github:VOTRE-USER/nixos-kid";
    # OU en local : nixos-kid.url = "path:/chemin/vers/nixos-kid";
  };

  outputs = { nixpkgs, nixos-kid, ... }: {
    nixosConfigurations.HOSTNAME = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        nixos-kid.nixosModules.kid-friendly
      ];
    };
  };
}
```

**b) Ajouter dans `/etc/nixos/configuration.nix` :**

```nix
{
  kid-friendly = {
    enable = true;
    username = "enfant";
    fullName = "Mon Enfant";
  };
}
```

**c) Reconstruire :**

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#HOSTNAME
```

### Sans Flake (alternative)

```bash
# Copier les modules
git clone https://github.com/VOTRE-USER/nixos-kid.git /tmp/nixos-kid
sudo cp -r /tmp/nixos-kid/modules /etc/nixos/

# Ajouter dans configuration.nix
imports = [ ./modules/kid-friendly.nix ];
kid-friendly.enable = true;

# Rebuild
sudo nixos-rebuild switch
```

## 3. Configuration Post-Installation

```bash
# Changer les mots de passe
sudo passwd parent
sudo passwd enfant

# Redémarrer
reboot
```

## 4. Vérifications

```bash
# Langue en français ?
echo $LANG  # fr_FR.UTF-8

# Clavier AZERTY ?
setxkbmap -query  # layout: fr

# DNS filtré ?
cat /etc/resolv.conf | grep 208.67  # OpenDNS

# Applications installées ?
which gcompris-qt tuxpaint supertux

# Enfant ne peut pas sudo ?
sudo -l -U enfant  # Devrait refuser
```

## 5. Configurations Spécifiques

### Machine ancienne (faible RAM)

```nix
kid-friendly = {
  desktopEnvironment = "xfce";  # Plus léger
  games.minetest = false;        # Jeux 3D désactivés
  games.supertuxkart = false;
};
```

### Plusieurs enfants

```nix
# Le premier enfant
kid-friendly.username = "alice";

# Créer les autres manuellement
users.users.bob = {
  isNormalUser = true;
  extraGroups = [ "audio" "video" ];
};
```

### Portable

```nix
services.tlp.enable = true;  # Gestion batterie
```

## Ressources

- **Doc NixOS** : https://nixos.org/manual/nixos/stable/
- **Options** : Voir [README.md](README.md)
- **Applications** : Voir [APPLICATIONS.md](APPLICATIONS.md)
- **Problèmes** : Voir [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Usage** : Voir [PARENTS.md](PARENTS.md)

## Matériel Recommandé

| Composant | Minimum | Recommandé |
|-----------|---------|------------|
| CPU | 2 cœurs | 4 cœurs |
| RAM | 4 GB | 8 GB |
| Disque | 30 GB | 60 GB (SSD) |
| GPU | Intégré | Dédié (pour jeux 3D) |

---

**Installation terminée !** Consultez [PARENTS.md](PARENTS.md) pour l'utilisation quotidienne.
