# Guide pour les Parents

Ce guide est destiné aux parents qui souhaitent installer et configurer NixOS Kid-Friendly pour leur enfant.

## Qu'est-ce que NixOS Kid-Friendly ?

NixOS Kid-Friendly est une configuration complète pour transformer un ordinateur sous NixOS en environnement :
- 🇫🇷 **100% en français** - Interface et applications
- 📚 **Éducatif** - Logiciels d'apprentissage adaptés
- 🎮 **Ludique** - Jeux appropriés pour enfants
- 🔒 **Sécurisé** - Contrôles parentaux intégrés
- 🛡️ **Protégé** - Filtrage de contenu automatique

## Installation - Version Simple

### Ce dont vous avez besoin
- Un ordinateur avec NixOS installé
- 30 minutes de temps
- Connaissances de base en informatique

### Étapes d'installation

1. **Téléchargez le projet**
   ```bash
   git clone https://github.com/VOTRE-REPO/nixos-kid.git
   cd nixos-kid
   ```

2. **Lancez l'installation**
   ```bash
   sudo ./install.sh mon-enfant
   ```
   (Remplacez "mon-enfant" par le nom de votre enfant)

3. **Suivez les instructions** affichées à l'écran

4. **Changez le mot de passe**
   ```bash
   sudo passwd mon-enfant
   ```

C'est tout ! L'ordinateur est prêt.

## Ce qui est installé

### Applications Éducatives 📚

#### GCompris ⭐ (INDISPENSABLE)
- Plus de 100 activités éducatives
- Mathématiques, français, sciences, jeux
- Âge : 2-10 ans
- **Notre recommandation #1**

#### Tux Paint (Dessin)
- Programme de dessin pour enfants
- Simple et amusant
- Tampons et effets créatifs
- Âge : 3-12 ans

#### Tux Typing (Clavier)
- Apprendre à taper au clavier
- Jeux amusants
- Progression adaptée
- Âge : 6-10 ans

#### Tux Math (Mathématiques)
- Calcul mental ludique
- Addition, soustraction, multiplication
- Mode arcade
- Âge : 4-10 ans

#### KTurtle (Programmation)
- Introduction à la programmation
- Langage Logo simplifié
- En français
- Âge : 8-14 ans

### Jeux 🎮

Tous les jeux sont **sans violence** et **adaptés aux enfants**.

#### SuperTux
- Jeu de plateforme (type Mario)
- Plusieurs mondes
- Âge : 5+ ans

#### SuperTuxKart
- Course de kart en 3D
- Multijoueur possible
- Coloré et amusant
- Âge : 5+ ans

#### Frozen Bubble
- Puzzle de bulles colorées
- Facile à comprendre
- Âge : 5+ ans

#### Minetest
- Type Minecraft
- Mode créatif activé
- Construction libre
- Âge : 7+ ans

#### Steam ⚠️ (Optionnel - NON activé par défaut)
- Plateforme avec milliers de jeux
- **NÉCESSITE SUPERVISION STRICTE**
- Activez impérativement le contrôle parental (Family View)
- Beaucoup de jeux ne sont PAS adaptés aux enfants
- Vérifiez l'âge PEGI/ESRB de chaque jeu
- **Configuration manuelle requise** : Définir un code PIN parental

**Jeux Steam kid-friendly** : Stardew Valley, Terraria, Slime Rancher, A Short Hike, Untitled Goose Game

### Sécurité 🔒

#### Filtrage DNS Automatique
- Bloque automatiquement les sites inappropriés
- Via OpenDNS FamilyShield
- Actif 24h/24
- Aucune configuration nécessaire

#### Navigateur Sécurisé
- Firefox configuré
- Page d'accueil : Qwant Junior (moteur de recherche pour enfants)
- Résultats filtrés
- Pas de publicités inappropriées

#### Restrictions
- Pas d'accès administrateur pour l'enfant
- Ne peut pas installer de logiciels
- Ne peut pas modifier les paramètres système

## Options de Contrôle Parental

### Limite de Temps d'Écran

Vous pouvez limiter le temps quotidien :

```nix
parental = {
  screenTimeLimit = "2h";  # 2 heures par jour
};
```

L'ordinateur déconnectera automatiquement l'enfant après le temps écoulé.

### Plages Horaires

Interdisez l'accès à certaines heures :

```nix
parental = {
  restrictedHours = [
    "20:00-08:00"   # Pas d'écran la nuit
    "12:00-14:00"   # Pause déjeuner
  ];
};
```

### Surveillance

Vous pouvez consulter :

**Temps passé aujourd'hui** :
```bash
cat /var/log/screen-time-enfant.log
```

**Historique de navigation** :
Via Firefox, Historique → Afficher tout l'historique

**Dernière connexion** :
```bash
last enfant
```

## Configuration par Âge

### Maternelle (3-5 ans)

Configuration recommandée :
- GCompris (activités simples)
- Tux Paint
- Frozen Bubble
- **Temps d'écran** : 30 min - 1h par jour
- **Surveillance** : Toujours avec un adulte

### Primaire (6-10 ans)

Configuration recommandée :
- GCompris complet
- Tux Paint, Tux Typing, Tux Math
- SuperTux, SuperTuxKart
- **Temps d'écran** : 1-2h par jour
- **Surveillance** : Régulière

### Collège (11-14 ans)

Configuration recommandée :
- KTurtle (programmation)
- GeoGebra (géométrie)
- Stellarium (astronomie)
- Minetest
- LibreOffice (devoirs)
- **Temps d'écran** : 2-3h par jour
- **Surveillance** : Occasionnelle

## Questions Fréquentes

### Mon enfant peut-il installer des jeux ?
Non, seul un administrateur (vous) peut installer des logiciels.

### Le filtrage Internet est-il efficace ?
Oui, mais aucun système n'est parfait à 100%. Une surveillance reste recommandée.

### Peut-on ajouter d'autres applications ?
Oui ! Consultez [APPLICATIONS.md](APPLICATIONS.md) pour la liste complète disponible.

### Comment désactiver temporairement les restrictions ?
Connectez-vous avec votre compte administrateur et modifiez la configuration.

### L'enfant peut-il contourner les restrictions ?
Non, pas sans connaissances techniques avancées. Le système est conçu pour être robuste.

### Que faire si une application ne fonctionne pas ?
Consultez [TROUBLESHOOTING.md](TROUBLESHOOTING.md) ou créez une issue GitHub.

## Modifier la Configuration

Pour changer les paramètres :

1. **Éditez le fichier de configuration**
   ```bash
   sudo nano /etc/nixos/configuration.nix
   ```

2. **Modifiez les options** selon vos besoins

3. **Appliquez les changements**
   ```bash
   sudo nixos-rebuild switch
   ```

4. **Redémarrez si nécessaire**

## Conseils d'Utilisation

### 💡 Bonnes Pratiques

- **Accompagnez votre enfant** les premières fois
- **Explorez GCompris ensemble** - il y a beaucoup d'activités !
- **Fixez des règles claires** sur l'utilisation
- **Variez les activités** (éducatif + jeux)
- **Encouragez la créativité** avec Tux Paint
- **Valorisez les créations** (imprimez les dessins !)

### ⚠️ Recommandations

- Ne laissez **jamais** votre mot de passe administrateur accessible
- **Surveillez** régulièrement l'activité
- **Discutez** avec votre enfant de ce qu'il fait sur l'ordinateur
- **Limitez** le temps d'écran selon l'âge
- **Encouragez** aussi les activités hors écran

### 🎯 Objectifs Éducatifs

Cet environnement permet d'apprendre :
- La manipulation de la souris et du clavier
- Les bases de la lecture et de l'écriture
- Les mathématiques de façon ludique
- La créativité (dessin, construction)
- La logique et la résolution de problèmes
- Les bases de la programmation (pour les plus grands)

## Ressources en Ligne Sécurisées

Sites recommandés (accessibles via Firefox) :

- **Qwant Junior** : https://www.qwantjunior.com/
  Moteur de recherche pour enfants (6-12 ans)

- **Lumni** : https://www.lumni.fr/
  Plateforme éducative de l'audiovisuel public

- **1jour1actu** : https://www.1jour1actu.com/
  Actualité pour les enfants

- **Il était une histoire** : https://www.iletaitunehistoire.com/
  Histoires et contes en ligne

- **Wikimini** : https://fr.wikimini.org/
  Encyclopédie pour enfants

## Support et Communauté

### Besoin d'aide ?

1. Consultez d'abord [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Lisez la [documentation complète](README.md)
3. Créez une [issue sur GitHub](https://github.com/VOTRE-REPO/nixos-kid/issues)

### Contribuer

Vous avez des suggestions ? Des applications à recommander ?
Consultez [CONTRIBUTING.md](CONTRIBUTING.md) !

## Mise à Jour

Pour mettre à jour vers la dernière version :

```bash
cd nixos-kid
git pull
sudo nixos-rebuild switch
```

## Désinstallation

Si vous souhaitez retirer cette configuration :

1. **Sauvegardez** les créations de l'enfant (dossiers Dessins, Créations, etc.)

2. **Désactivez** dans la configuration :
   ```nix
   kid-friendly.enable = false;
   ```

3. **Reconstruisez** :
   ```bash
   sudo nixos-rebuild switch
   ```

## Remerciements

Merci d'avoir choisi NixOS Kid-Friendly pour votre enfant !

Ce projet est conçu pour offrir un environnement informatique :
- Sûr
- Éducatif
- Adapté à l'âge
- Entièrement en français

Nous espérons que votre enfant apprendra en s'amusant ! 🎓🎮

---

**Questions ? Suggestions ?**
N'hésitez pas à nous contacter via GitHub !

**Licence** : MIT
**Gratuit** et open source
