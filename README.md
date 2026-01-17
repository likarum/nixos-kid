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
- ✅ **Utilisateur sans sudo** : Enfant ne peut pas modifier la config système
- ✅ **Secrets séparés** : Mots de passe dans fichier externe non-commité

## 🏗️ Architecture

```
Applications (Firefox, Chromium, etc.)
         │ DoH bloqué par policies + firewall
         ▼
AdGuard Home (127.0.0.1:53)
  - SafeSearch forcé
  - Listes de blocage
  - Filtrage parental
         │ Upstream DNS queries (DoH)
         ▼
Providers DNS autorisés UNIQUEMENT
  - AdGuard DNS (94.140.14.14)
  - DNS0.eu (193.110.81.0)
  - Mullvad DNS (194.242.2.2)
```

## 📦 Modules

| Module | Description |
|--------|-------------|
| [adguard-home.nix](modules/adguard-home.nix) | AdGuard Home avec config immuable |
| [dns-enforcement.nix](modules/dns-enforcement.nix) | Force DNS local uniquement |
| [browser-policies.nix](modules/browser-policies.nix) | Policies Firefox/Chromium anti-DoH |
| [firewall.nix](modules/firewall.nix) | Blocage firewall DoH providers |

## 🚀 Installation (avec flakes)

### 1. Cloner ce dépôt dans /etc/nixos

```bash
cd /etc/nixos
git clone https://github.com/VOTRE-USERNAME/nixos-kid.git
```

### 2. Créer le fichier secrets.nix

```bash
cd /etc/nixos/nixos-kid
cp secrets.nix.example secrets.nix
```

### 3. Générer le hash bcrypt pour AdGuard Home

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

### 4. Éditer secrets.nix

Ouvrez `/etc/nixos/nixos-kid/secrets.nix` et remplacez les valeurs :

```nix
{
  # Hash bcrypt du mot de passe admin AdGuard Home
  adguardAdminPasswordHash = "$2y$10$VOTRE_HASH_ICI";

  # Subnet de votre réseau local (adapter selon votre réseau)
  lanSubnet = "192.168.1.0/24";

  # Mot de passe initial pour l'utilisateur enfant
  childInitialPassword = "changeme";

  # Nom d'utilisateur de l'enfant
  childUsername = "enfant";

  # Nom complet de l'enfant
  childFullName = "Mon Enfant";
}
```

**IMPORTANT** : Le fichier `secrets.nix` est dans `.gitignore` et ne sera **JAMAIS** commité. Gardez-le en sécurité !

### 5. Créer votre flake.nix

Créez `/etc/nixos/flake.nix` (voir [example-flake.nix](example-flake.nix)) :

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

### 6. Créer votre configuration.nix

Créez `/etc/nixos/configuration.nix` (voir [flake-configuration.nix](flake-configuration.nix)) :

```nix
{ config, pkgs, ... }:

let
  # Importer le fichier secrets
  secrets = import ./nixos-kid/secrets.nix;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  kidFriendly = {
    adguardHome = {
      enable = true;
      adminPasswordHash = secrets.adguardAdminPasswordHash;
      lanSubnet = secrets.lanSubnet;
    };

    dnsEnforcement.enable = true;

    browserPolicies = {
      enable = true;
      firefox.enable = true;
      chromium.enable = true;
    };

    firewall = {
      enable = true;
      lanSubnet = secrets.lanSubnet;
      blockDoHProviders = true;
    };

    user = {
      enable = true;
      username = secrets.childUsername;
      fullName = secrets.childFullName;
      initialPassword = secrets.childInitialPassword;
      extraGroups = [ "networkmanager" "video" "audio" ];

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
  };

  # Configuration système (hostname, locale, desktop, etc.)
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

  # Compte admin parent
  users.users.admin = {
    isNormalUser = true;
    description = "Parent Admin";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  system.stateVersion = "24.05";
}
```

### 7. Appliquer la configuration

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
├── configuration.nix            # Votre config (importe secrets.nix)
└── nixos-kid/                   # Ce dépôt git
    ├── flake.nix
    ├── secrets.nix              # VOS SECRETS (non-commité)
    ├── secrets.nix.example      # Modèle
    ├── modules/
    │   ├── adguard-home.nix
    │   ├── dns-enforcement.nix
    │   ├── browser-policies.nix
    │   └── firewall.nix
    └── README.md
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

### Test 4 : Blocage DoT

```bash
# DNS-over-TLS port 853 (doit échouer)
kdig +tls @1.1.1.1 google.com
# Connection refused
```

### Test 5 : Policies navigateurs

**Firefox :**
1. Ouvrir `about:config`
2. Chercher `network.trr.mode`
3. Doit être à `5` et **verrouillé**

**Chromium :**
1. Ouvrir `chrome://policy`
2. Vérifier `DnsOverHttpsMode` = `"off"`

### Test 6 : Interface admin AdGuard Home

```bash
# Depuis un autre appareil sur le LAN
http://IP_DU_LAPTOP:3000

# Login : admin
# Mot de passe : celui utilisé pour générer le hash
```

## 🔧 Personnalisation

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

**Important :** Ajoutez aussi les IPs correspondantes dans `allowedDNSIPs` de [modules/firewall.nix](modules/firewall.nix).

### Créer l'utilisateur enfant

Dans votre `configuration.nix`, créez un utilisateur standard **sans groupe wheel** :

```nix
users.users.enfant = {
  isNormalUser = true;
  description = "Mon Enfant";
  # PAS de groupe wheel = PAS de sudo
  extraGroups = [ "networkmanager" "video" "audio" ];

  # Applications pour l'utilisateur
  packages = with pkgs; [
    firefox
    chromium
    gcompris      # Éducatif
    tuxmath       # Maths
    tuxpaint      # Dessin
    libreoffice
    vlc
  ];
};

# Définir le mot de passe après installation:
# sudo passwd enfant
```

### Bloquer/Autoriser des domaines

Dans [modules/adguard-home.nix](modules/adguard-home.nix), section `user_rules` :

```nix
user_rules = [
  # Bloquer
  "||example.com^"

  # Autoriser (whitelist)
  "@@||trusted-site.com^"
];
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
```

### Interface admin inaccessible

```bash
sudo ss -tulpn | grep 3000
sudo iptables -L INPUT -n | grep 3000
```

### DNS ne fonctionne pas

```bash
cat /etc/resolv.conf
dig @127.0.0.1 google.com
curl http://127.0.0.1:3000
```

### Erreur "secrets.nix not found"

Assurez-vous d'avoir créé `/etc/nixos/nixos-kid/secrets.nix` à partir de `secrets.nix.example`.

## 📚 Ressources

- [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOS Firewall](https://nixos.wiki/wiki/Firewall)

## ⚠️ Avertissement

**Aucun système n'est infaillible à 100%**. Cette configuration offre un bon niveau de protection, mais :

- Surveillez régulièrement l'activité réseau
- Discutez avec l'enfant de sécurité en ligne
- Adaptez selon l'âge et la maturité
- Gardez le système à jour
- **Sécurisez votre fichier `secrets.nix`** (permissions 600 recommandées)

## 📄 Licence

MIT - Voir [LICENSE](LICENSE)
