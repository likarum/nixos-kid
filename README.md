# NixOS Kid-Friendly - Filtrage DNS robuste

Configuration NixOS pour laptop enfant avec **filtrage DNS local via AdGuard Home**, impossible à contourner.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║                           ⚠️  DISCLAIMERS IMPORTANTS  ⚠️                      ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  🚫 AUCUNE GARANTIE                                                           ║
║  Ce projet est fourni "TEL QUEL", SANS AUCUNE GARANTIE d'aucune sorte.      ║
║  Je ne prends AUCUNE RESPONSABILITÉ quant à son utilisation, ses bugs        ║
║  éventuels, ou tout problème qui pourrait survenir.                          ║
║                                                                               ║
║  🧪 PROJET EXPÉRIMENTAL                                                       ║
║  Ce projet a été créé PRINCIPALEMENT pour TESTER les capacités de            ║
║  Claude (Anthropic) dans la génération de configurations NixOS.              ║
║  L'objectif principal est l'EXPÉRIMENTATION avec l'IA, pas nécessairement   ║
║  la production d'un système ultra-robuste (même si je vais probablement      ║
║  le déployer quand même).                                                     ║
║                                                                               ║
║  👨‍👩‍👧 CONTRÔLES PARENTAUX NON INFAILLIBLES                                      ║
║  Les mécanismes de contrôle parental (DNS filtré, restrictions) ne sont      ║
║  PAS INFAILLIBLES. Une SURVEILLANCE ACTIVE des parents reste INDISPENSABLE.  ║
║  Ne vous reposez PAS uniquement sur ces outils techniques.                   ║
║                                                                               ║
║  🧠 RÉFLEXION PHILOSOPHIQUE                                                   ║
║  Si votre enfant possède les compétences techniques pour lire et comprendre  ║
║  ce code NixOS, ou pour bypasser ce système de filtrage, il a probablement   ║
║  atteint un niveau de maturité technique qui remet en question la pertinence ║
║  même d'un contrôle parental technique. À ce stade, le dialogue et la        ║
║  confiance deviennent plus efficaces que les restrictions techniques.        ║
║                                                                               ║
║  ⚡ UTILISATION À VOS RISQUES ET PÉRILS                                       ║
║  VOUS êtes RESPONSABLE de la configuration et de l'utilisation de ce         ║
║  système pour vos enfants. TESTEZ TOUJOURS dans un environnement de test     ║
║  avant déploiement réel.                                                      ║
║                                                                               ║
║  📝 Generated with Claude AI - Use at your own risk                          ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 🎯 Objectifs

- ✅ **Filtrage DNS local** : AdGuard Home sur `127.0.0.1:53`
- ✅ **Blocage DoH/DoT** : Impossible de bypass via DNS-over-HTTPS ou DNS-over-TLS
- ✅ **Policies navigateurs** : Firefox et Chromium verrouillés anti-DoH
- ✅ **Firewall strict** : Blocage IPs DoH publics (Cloudflare, Google, Quad9)
- ✅ **Blocage services** : Réseaux sociaux, gaming platforms, streaming (sauf Steam)
- ✅ **Utilisateur sans sudo** : Enfant ne peut pas modifier la config système
- ✅ **Secrets chiffrés** : Gestion sécurisée avec sops-nix (age encryption)

## 🏗️ Architecture

```
Applications (Firefox, Chromium, etc.)
         │ DoH bloqué par policies + firewall
         ▼
AdGuard Home (127.0.0.1:53)
  - SafeSearch forcé
  - Listes de blocage (porn, gambling, malware)
  - Filtrage parental
  - Blocage services (Facebook, TikTok, etc.)
         │ Bootstrap DNS (UDP port 53)
         ▼
Bootstrap DNS (94.140.14.14, 193.110.81.0)
         │ Upstream DNS queries (DoH via port 443)
         ▼
Providers DNS autorisés UNIQUEMENT
  - AdGuard DNS (94.140.14.14)
  - DNS0.eu (193.110.81.0)
  - Mullvad DNS (194.242.2.2)
```

## 📦 Modules

| Module | Description |
|--------|-------------|
| [sops.nix](modules/sops.nix) | Gestion secrets avec sops-nix (age) |
| [adguard-home.nix](modules/adguard-home.nix) | AdGuard Home avec config immuable |
| [dns-enforcement.nix](modules/dns-enforcement.nix) | Force DNS local uniquement |
| [browser-policies.nix](modules/browser-policies.nix) | Policies Firefox/Chromium anti-DoH |
| [firewall.nix](modules/firewall.nix) | Blocage firewall DoH + bootstrap DNS |
| [services-blocklist.nix](modules/services-blocklist.nix) | Blocage services (social media, gaming) |

## 🚀 Installation (avec flakes)

### 1. Cloner ce dépôt dans /etc/nixos

```bash
cd /etc/nixos
git clone https://github.com/likarum/nixos-kid.git
```

### 2. Générer la clé age pour sops

```bash
# Créer le répertoire
sudo mkdir -p /var/lib/sops-nix

# Générer la clé age
sudo age-keygen -o /var/lib/sops-nix/key.txt

# Afficher la clé publique (pour .sops.yaml)
sudo age-keygen -y /var/lib/sops-nix/key.txt
```

**Exemple de sortie :**
```
Public key: age1abc123xyz789EXEMPLE
```

### 3. Configurer .sops.yaml

Éditez `/etc/nixos/nixos-kid/.sops.yaml` et remplacez `YOUR_AGE_PUBLIC_KEY` par votre clé publique :

```yaml
keys:
  - &admin age1abc123xyz789EXEMPLE  # Votre clé publique ici

creation_rules:
  - path_regex: secrets\.yaml$
    key_groups:
      - age:
          - *admin
```

### 4. Générer le hash bcrypt pour AdGuard Home

```bash
# Entrer dans un shell avec htpasswd
nix-shell -p apacheHttpd

# Générer le hash (remplacer "VotreMotDePasse" par votre mot de passe admin)
htpasswd -B -n -b admin VotreMotDePasse
```

**Exemple de sortie :**
```
admin:$2y$10$abc123xyz789EXEMPLE_HASH
```

Copiez la partie après `admin:` (le hash commençant par `$2y$10$`)

### 5. Créer et éditer secrets.yaml avec sops

```bash
cd /etc/nixos/nixos-kid

# Copier l'exemple
cp secrets.yaml.example secrets.yaml

# Éditer avec sops (ouvrira votre éditeur)
sops secrets.yaml
```

Remplacez les valeurs par les vôtres :

```yaml
# Hash bcrypt du mot de passe admin AdGuard Home
adguard-admin-password: $2y$10$VOTRE_HASH_ICI

# Mot de passe initial pour l'utilisateur enfant (sera hashé automatiquement)
child-initial-password: changeme

# Nom d'utilisateur de l'enfant
child-username: enfant

# Nom complet de l'enfant
child-fullname: Mon Enfant
```

**Sauvegardez et quittez.** Le fichier sera automatiquement chiffré avec age.

### 6. Créer votre flake.nix

Créez `/etc/nixos/flake.nix` :

```nix
{
  description = "Configuration NixOS laptop enfant";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Chemin local vers le flake nixos-kid
    nixos-kid.url = "path:/etc/nixos/nixos-kid";
  };

  outputs = { self, nixpkgs, nixos-kid }: {
    nixosConfigurations.laptop-enfant = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        nixos-kid.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
```

### 7. Créer votre configuration.nix

Créez `/etc/nixos/configuration.nix` :

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ===================================================================
  # CONFIGURATION KIDFRIENDLY
  # ===================================================================

  kidFriendly = {
    # SOPS secrets management
    sops.enable = true;

    # AdGuard Home
    adguardHome = {
      enable = true;
      # Le hash sera lu depuis config.sops.secrets.adguard-admin-password.path
    };

    # DNS enforcement
    dnsEnforcement.enable = true;

    # Browser policies
    browserPolicies = {
      enable = true;
      firefox.enable = true;
      chromium.enable = true;
    };

    # Firewall
    firewall = {
      enable = true;
      blockDoHProviders = true;
    };

    # Services blocklist (tout bloqué sauf Steam)
    servicesBlocklist = {
      enable = true;
      # Steam est autorisé par défaut (blockSteam = false)
      # Pour personnaliser, voir section Personnalisation ci-dessous
    };
  };

  # ===================================================================
  # CONFIGURATION SYSTÈME
  # ===================================================================

  networking.hostName = "laptop-enfant";
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";

  # Desktop environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb.layout = "fr";
  };

  # Audio
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  networking.networkmanager.enable = true;

  # Compte admin parent (avec sudo)
  users.users.admin = {
    isNormalUser = true;
    description = "Parent Admin";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Compte enfant (SANS sudo - pas de groupe wheel)
  users.users.enfant = {
    isNormalUser = true;
    description = "Enfant";
    extraGroups = [ "networkmanager" "video" "audio" ];
    # Le mot de passe sera lu depuis sops
    hashedPasswordFile = config.sops.secrets."child-initial-password".path;

    packages = with pkgs; [
      firefox
      chromium
      gcompris
      tuxmath
      tuxpaint
      libreoffice
      kate
      vlc
    ];
  };

  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
    git
    dig
    sops     # Pour éditer secrets.yaml
    age      # Pour la gestion des clés
  ];

  system.stateVersion = "25.11";
}
```

### 8. Appliquer la configuration

```bash
# Première fois : générer flake.lock
sudo nix flake update /etc/nixos

# Appliquer la configuration
sudo nixos-rebuild switch --flake /etc/nixos#laptop-enfant
```

## 📁 Structure des fichiers

Votre `/etc/nixos` devrait ressembler à :

```
/etc/nixos/
├── flake.nix                    # Votre flake principal
├── flake.lock                   # Généré automatiquement
├── hardware-configuration.nix   # Généré par nixos-generate-config
├── configuration.nix            # Votre config
└── nixos-kid/                   # Ce dépôt git
    ├── flake.nix
    ├── .sops.yaml               # Config sops (avec votre clé publique)
    ├── secrets.yaml             # SECRETS CHIFFRÉS (commitable)
    ├── secrets.yaml.example     # Modèle
    ├── modules/
    │   ├── sops.nix
    │   ├── adguard-home.nix
    │   ├── dns-enforcement.nix
    │   ├── browser-policies.nix
    │   ├── firewall.nix
    │   └── services-blocklist.nix
    └── README.md

/var/lib/sops-nix/
└── key.txt                      # Clé privée age (NE JAMAIS COMMITTER)
```

## 🧪 Tests de sécurité

### Test 1 : DNS local forcé

```bash
cat /etc/resolv.conf
# Doit afficher : nameserver 127.0.0.1
```

### Test 2 : Blocage DoH

```bash
# Cloudflare DoH (doit échouer)
curl -I https://1.1.1.1
# Connection refused

# Google DoH (doit échouer)
curl -I https://8.8.8.8
# Connection refused
```

### Test 3 : Blocage DNS externe

```bash
# DNS Google sur port 53 (doit échouer)
dig @8.8.8.8 google.com
# Connection refused
```

### Test 4 : Bootstrap DNS autorisé

```bash
# AdGuard DNS bootstrap (doit fonctionner - nécessaire pour AdGuard Home)
dig @94.140.14.14 google.com
# Doit renvoyer une réponse

# DNS0.eu bootstrap (doit fonctionner)
dig @193.110.81.0 google.com
# Doit renvoyer une réponse
```

### Test 5 : Blocage DoT

```bash
# DNS-over-TLS port 853 (doit échouer)
kdig +tls @1.1.1.1 google.com
# Connection refused
```

### Test 6 : Policies navigateurs

**Firefox :**
1. Ouvrir `about:config`
2. Chercher `network.trr.mode`
3. Doit être à `5` et **verrouillé**

**Chromium :**
1. Ouvrir `chrome://policy`
2. Vérifier `DnsOverHttpsMode` = `"off"`

### Test 7 : Blocage services

```bash
# Tester depuis le compte enfant
ping facebook.com       # Doit être bloqué
ping twitter.com        # Doit être bloqué
ping steampowered.com   # Doit fonctionner (Steam autorisé)
```

### Test 8 : Interface admin AdGuard Home

```bash
# Depuis un navigateur sur le LAN
http://IP_DU_LAPTOP:3000

# Login : admin
# Mot de passe : celui utilisé pour générer le hash
```

## 🔧 Personnalisation

### Modifier les services bloqués

Par défaut, **tout est bloqué sauf Steam**. Pour personnaliser :

```nix
kidFriendly.servicesBlocklist = {
  enable = true;

  # Autoriser certains services
  blockFacebook = false;      # Autoriser Facebook
  blockYouTube = false;       # Autoriser YouTube
  blockDiscord = false;       # Autoriser Discord

  # Bloquer Steam (par défaut autorisé)
  blockSteam = true;

  # Règles personnalisées
  customRules = [
    "||custom-site.com^"      # Bloquer un site
    "@@||allowed-site.com^"   # Autoriser un site (whitelist)
  ];
};
```

**Services disponibles :**
- `blockFacebook` : Facebook, Instagram
- `blockTwitter` : Twitter/X
- `blockTikTok` : TikTok
- `blockSnapchat` : Snapchat
- `blockReddit` : Reddit
- `blockDiscord` : Discord
- `blockEpicGames` : Epic Games Store
- `blockRiotGames` : League of Legends, Valorant
- `blockBlizzard` : Battle.net
- `blockEA` : EA/Origin
- `blockUbisoft` : Ubisoft
- `blockGOG` : GOG
- `blockTwitch` : Twitch
- `blockYouTube` : YouTube
- `blockNetflix` : Netflix
- `blockFortnite` : Fortnite
- `blockRoblox` : Roblox
- `blockMinecraftUnofficial` : Serveurs Minecraft non-officiels
- `blockSteam` : Steam (défaut: `false`)

### Changer les upstreams DNS

Éditez [modules/adguard-home.nix](modules/adguard-home.nix) :

```nix
upstream_dns = [
  "https://dns.adguard-dns.com/dns-query"
  "https://dns0.eu/"
  "https://dns.mullvad.net/dns-query"
  # Ajoutez vos upstreams ici
];
```

**Important :** Ajoutez aussi les IPs correspondantes dans `allowedDNSIPs` et `bootstrapDNSIPs` de [modules/firewall.nix](modules/firewall.nix).

### Bloquer/Autoriser des domaines additionnels

Via le module AdGuard Home :

```nix
kidFriendly.adguardHome = {
  enable = true;
  extraUserRules = [
    # Bloquer
    "||example.com^"
    "||badsite.net^"

    # Autoriser (whitelist)
    "@@||trusted-site.com^"
  ];
};
```

### Éditer les secrets

```bash
cd /etc/nixos/nixos-kid
sops secrets.yaml
```

## 🔄 Mise à jour

Pour mettre à jour le flake nixos-kid :

```bash
cd /etc/nixos/nixos-kid
git pull

# Puis reconstruire
sudo nixos-rebuild switch --flake /etc/nixos#laptop-enfant
```

## 🛠️ Dépannage

### AdGuard Home ne démarre pas

```bash
sudo journalctl -u adguardhome -f
sudo lsof -i :53

# Vérifier si un autre service utilise le port 53
sudo systemctl status systemd-resolved
```

### Interface admin inaccessible

```bash
sudo ss -tulpn | grep 3000
sudo iptables -L INPUT -n | grep 3000

# Vérifier les logs AdGuard
sudo journalctl -u adguardhome -n 50
```

### DNS ne fonctionne pas

```bash
cat /etc/resolv.conf
dig @127.0.0.1 google.com
curl http://127.0.0.1:3000

# Vérifier les règles firewall
sudo iptables -L OUTPUT -n | grep 53
```

### Erreur sops "no key found"

```bash
# Vérifier que la clé age existe
sudo cat /var/lib/sops-nix/key.txt

# Vérifier .sops.yaml
cat /etc/nixos/nixos-kid/.sops.yaml

# Régénérer secrets.yaml si nécessaire
cd /etc/nixos/nixos-kid
cp secrets.yaml.example secrets.yaml
sops secrets.yaml
```

### Bootstrap DNS ne fonctionne pas

```bash
# Vérifier les règles firewall bootstrap
sudo iptables -L OUTPUT -n | grep 94.140.14.14
sudo iptables -L OUTPUT -n | grep 193.110.81.0

# Tester manuellement
dig @94.140.14.14 google.com
```

## 📚 Listes de blocage actives

Le module AdGuard Home utilise les listes suivantes (mises à jour automatiquement) :

1. **AdGuard DNS filter** - Blocage ads généraux
2. **AdAway Default Blocklist** - Blocage ads mobiles
3. **StevenBlack Unified hosts** - Blocage malware/ads
4. **StevenBlack Fakenews + Gambling + Porn** - Contenus inappropriés
5. **BlockList Project - Porn** - Contenus pornographiques
6. **BlockList Project - Gambling** - Sites de jeux d'argent
7. **BlockList Project - Redirect** - Redirections malveillantes
8. **HaGeZi Pro Blocklist** - Liste complète et maintenue

## 🔐 Sécurité des secrets

### Sauvegarde de la clé age

**CRITIQUE :** Sauvegardez `/var/lib/sops-nix/key.txt` dans un endroit sûr (coffre-fort de mots de passe, clé USB chiffrée, etc.). Sans cette clé, vous ne pourrez plus déchiffrer vos secrets !

```bash
# Sauvegarder la clé (à faire IMMÉDIATEMENT après génération)
sudo cp /var/lib/sops-nix/key.txt ~/backup-age-key.txt
chmod 600 ~/backup-age-key.txt
# Copier ce fichier dans un endroit sûr puis le supprimer
```

### Permissions

```bash
# Vérifier les permissions de la clé
sudo ls -l /var/lib/sops-nix/key.txt
# Doit être: -rw------- 1 root root

# Permissions du fichier secrets.yaml
ls -l /etc/nixos/nixos-kid/secrets.yaml
# Peut être -rw-r--r-- (le fichier est chiffré)
```

## 📚 Ressources

- [sops-nix](https://github.com/Mic92/sops-nix) - Secrets Operations pour NixOS
- [age](https://github.com/FiloSottile/age) - Simple, modern encryption tool
- [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) - DNS filtering
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Flakes](https://nixos.wiki/wiki/Flakes)

## ⚠️ Avertissement

**Aucun système n'est infaillible à 100%**. Cette configuration offre un bon niveau de protection, mais :

- Surveillez régulièrement l'activité réseau
- Discutez avec l'enfant de sécurité en ligne
- Adaptez selon l'âge et la maturité
- Gardez le système à jour
- **Sauvegardez votre clé age** dans un endroit sûr
- **Ne commitez JAMAIS** `/var/lib/sops-nix/key.txt`

## 📄 Licence

MIT - Voir [LICENSE](LICENSE)
