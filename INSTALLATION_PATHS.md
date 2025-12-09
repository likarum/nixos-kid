# Quel Guide Utiliser ?

Guide rapide pour savoir quelle documentation lire.

## Selon Votre Situation

```
Vous avez NixOS installé ?
    │
    ├─ NON → [INSTALLATION.md] (Installation complète)
    │
    └─ OUI → Vous connaissez les flakes ?
              │
              ├─ NON → [QUICKSTART.md] (Installation rapide)
              │
              └─ OUI → [README.md] (Documentation technique)
```

## Guide des Documents

| Document | Quand l'utiliser | Temps |
|----------|------------------|-------|
| [INSTALLATION.md](INSTALLATION.md) | Installation NixOS + Kid-Friendly de zéro | 1h |
| [QUICKSTART.md](QUICKSTART.md) | NixOS déjà installé, ajouter Kid-Friendly | 10 min |
| [README.md](README.md) | Configuration avancée, options détaillées | 20 min |
| [PARENTS.md](PARENTS.md) | Utilisation quotidienne, surveillance | 15 min |
| [APPLICATIONS.md](APPLICATIONS.md) | Découvrir les applications disponibles | 30 min |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | En cas de problème | Variable |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Pour contribuer au projet | 10 min |

## Scénarios Courants

### 🆕 Je découvre NixOS
1. Installer NixOS : [INSTALLATION.md](INSTALLATION.md) section 1
2. Installer Kid-Friendly : [INSTALLATION.md](INSTALLATION.md) section 2
3. Comprendre l'usage : [PARENTS.md](PARENTS.md)

### ✅ J'ai déjà NixOS
1. Installer Kid-Friendly : [QUICKSTART.md](QUICKSTART.md)
2. Personnaliser : [README.md](README.md) section Configuration

### 👨‍👩‍👧‍👦 Plusieurs enfants
1. Installation de base : [INSTALLATION.md](INSTALLATION.md)
2. Multi-utilisateurs : [INSTALLATION.md](INSTALLATION.md) section 5

### 🔧 Matériel spécifique
- Machine ancienne → [INSTALLATION.md](INSTALLATION.md) section 5
- Portable → [INSTALLATION.md](INSTALLATION.md) section 5
- GPU NVIDIA → [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### ❌ Problème
1. Chercher dans [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Sinon, créer une [issue GitHub](https://github.com/VOTRE-REPO/nixos-kid/issues)

## Ordre de Lecture Recommandé

**Débutant** :
1. INSTALLATION.md
2. PARENTS.md
3. APPLICATIONS.md (optionnel)

**Utilisateur NixOS** :
1. QUICKSTART.md
2. PARENTS.md

**Expert** :
1. README.md
2. Code source dans `modules/`
