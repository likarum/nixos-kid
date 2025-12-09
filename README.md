# NixOS Kid-Friendly Configuration

Configuration NixOS pour un environnement enfant avec applications éducatives et jeux en français.

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

## Caractéristiques

- 🇫🇷 **Interface 100% en français** - Système et applications configurés en français
- 🎓 **Applications éducatives** - GCompris, Tux Paint, Childsplay, et plus
- 🎮 **Jeux adaptés** - SuperTux, Frozen Bubble, et autres jeux kid-friendly
- 🔒 **Contrôles parentaux** - Restrictions et sécurité intégrées
- 🖥️ **Interface simple** - Environnement de bureau adapté aux enfants

## Structure du projet

```
.
├── flake.nix              # Point d'entrée du flake
├── modules/
│   ├── kid-friendly.nix   # Module principal
│   ├── education.nix      # Applications éducatives
│   ├── games.nix          # Jeux
│   └── parental.nix       # Contrôles parentaux
└── README.md
```

## Installation

> **📚 Vous partez de zéro ?**
>
> Consultez le **[Guide d'Installation Complet](INSTALLATION.md)** qui couvre :
> - ✅ Installation de NixOS depuis une clé USB
> - ✅ Partitionnement et configuration matérielle
> - ✅ Installation pas-à-pas de Kid-Friendly
> - ✅ Configuration pour machines anciennes, portables, multi-utilisateurs
> - ✅ Vérifications et tests post-installation

### Intégration dans une configuration NixOS existante

1. Ajoutez ce flake à votre `flake.nix` :

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-kid.url = "path:/home/likarum/git/aquali/nixos-kid";
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

2. Dans votre `configuration.nix`, activez le module :

```nix
{
  kid-friendly = {
    enable = true;
    username = "enfant";  # Nom d'utilisateur de l'enfant
  };
}
```

3. Reconstruisez votre système :

```bash
sudo nixos-rebuild switch --flake .#votre-machine
```

## Configuration

Le module propose plusieurs options :

```nix
{
  kid-friendly = {
    enable = true;
    username = "enfant";

    # Applications éducatives
    education = {
      enable = true;
      gcompris = true;      # Suite éducative complète
      tuxpaint = true;      # Dessin pour enfants
      childsplay = true;    # Jeux éducatifs
    };

    # Jeux
    games = {
      enable = true;
      supertux = true;      # Plateforme type Mario
      frozenBubble = true;  # Puzzle bulles
      tuxRacer = true;      # Course de pingouin
      steam = true;         # Steam (optionnel) - milliers de jeux
    };

    # Contrôles parentaux
    parental = {
      enable = true;
      blockAdultContent = true;
      timeRestrictions = true;
    };
  };
}
```

## Applications incluses

### Éducatives
- **GCompris** - Plus de 100 activités éducatives
- **Tux Paint** - Dessin et créativité
- **Childsplay** - Jeux éducatifs variés
- **Tux Typing** - Apprentissage du clavier
- **Kturtle** - Programmation pour enfants

### Jeux
- **SuperTux** - Jeu de plateforme
- **Frozen Bubble** - Puzzle
- **SuperTuxKart** - Course de kart
- **Minetest** - Type Minecraft
- **Steam** (optionnel) - Plateforme avec milliers de jeux
- **PySolFC** - Jeux de cartes
- Et 10+ autres jeux

## Licence

MIT
