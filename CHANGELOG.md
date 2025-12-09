# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.0.0] - 2025-12-09

### Ajouté
- Module principal `kid-friendly.nix` avec configuration complète
- Module `education.nix` avec applications éducatives
  - GCompris (suite éducative de 100+ activités)
  - Tux Paint (dessin pour enfants)
  - Childsplay (jeux éducatifs)
  - Tux Typing (apprentissage du clavier)
  - KTurtle (programmation Logo)
  - gBrainy (jeux de logique)
  - PySioGame (activités éducatives)
  - Tux Math (mathématiques)
  - LibreOffice (suite bureautique)
  - GeoGebra (géométrie interactive)
  - Stellarium (planétarium)

- Module `games.nix` avec jeux adaptés aux enfants
  - SuperTux (plateforme 2D)
  - SuperTuxKart (course de kart 3D)
  - Frozen Bubble (puzzle)
  - Extreme Tux Racer (course de pingouin)
  - Minetest (type Minecraft)
  - PySolFC (jeux de cartes)
  - Jeux GNOME (2048, Quadrapassel, Aisleriot, etc.)
  - Pingus (type Lemmings)
  - Neverball (jeu d'adresse)
  - LBreakout2 (casse-briques)
  - Bomber Clone (type Bomberman)

- Module `parental.nix` avec contrôles parentaux
  - Filtrage DNS (OpenDNS FamilyShield)
  - Blocage des droits root/sudo
  - Configuration Firefox sécurisée avec Qwant Junior
  - Limite de temps d'écran quotidien
  - Restrictions horaires configurable
  - Service de monitoring du temps d'écran

- Configuration complète en français
  - Locale fr_FR.UTF-8
  - Clavier AZERTY
  - Toutes les applications en français
  - Variables d'environnement forcées en français

- Support de trois environnements de bureau
  - GNOME (par défaut)
  - KDE Plasma
  - XFCE

- Connexion automatique configurable
- Création automatique de l'utilisateur enfant
- Dossiers prédéfinis (Créations, Dessins, Devoirs)

### Documentation
- README.md complet avec instructions d'installation
- APPLICATIONS.md détaillant toutes les applications
- TROUBLESHOOTING.md pour résoudre les problèmes courants
- example-configuration.nix pour faciliter l'intégration
- LICENSE MIT
- Ce CHANGELOG

### Fonctionnalités
- Architecture modulaire permettant d'activer/désactiver chaque fonctionnalité
- Configuration par flake pour faciliter l'intégration
- Support de l'accélération matérielle pour les jeux 3D
- Configuration audio complète (PipeWire)
- Support de l'impression
- Polices adaptées et lisibles

### Sécurité
- DNS filtré par défaut
- Navigateur avec page d'accueil sécurisée (Qwant Junior)
- Pas d'accès root pour l'enfant
- Mode Safe Browsing activé
- Blocage des pop-ups

## [Prévu pour les prochaines versions]

### [1.1.0] - À venir
- Ajout de profils par âge (3-5 ans, 6-8 ans, 9-12 ans, 13+)
- Interface de configuration graphique pour les parents
- Dashboard de monitoring du temps d'écran
- Support de comptes multiples enfants
- Rapports d'activité hebdomadaires
- Synchronisation cloud des créations (optionnel)

### [1.2.0] - À venir
- Intégration de plus d'applications éducatives
- Support de tablettes graphiques
- Mode "devoirs" avec applications limitées
- Système de récompenses/achievements
- Support de contrôleurs de jeu
- Mode kiosque complet

### Idées futures
- Application mobile companion pour les parents
- IA pour suggestions d'activités éducatives
- Support de contenus éducatifs en ligne (videos, podcasts)
- Intégration avec les programmes scolaires français
- Contrôle parental avancé avec filtrage par catégories
- Support de profils d'apprentissage personnalisés
- Mode multijoueur local pour activités en famille

---

## Comment contribuer

Vos suggestions sont les bienvenues ! Pour proposer une nouvelle fonctionnalité :

1. Créez une issue sur GitHub décrivant la fonctionnalité
2. Discutez-en avec la communauté
3. Soumettez une pull request

## Versioning

- **MAJOR** : Changements incompatibles avec les versions précédentes
- **MINOR** : Ajout de fonctionnalités compatibles
- **PATCH** : Corrections de bugs
