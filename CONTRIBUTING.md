# Guide de Contribution

Merci de votre intérêt pour contribuer à NixOS Kid-Friendly ! Ce document explique comment participer au projet.

## Comment contribuer ?

Il existe plusieurs façons de contribuer :

1. **Rapporter des bugs** - Signalez les problèmes que vous rencontrez
2. **Suggérer des fonctionnalités** - Proposez de nouvelles idées
3. **Améliorer la documentation** - Corrigez ou enrichissez la documentation
4. **Soumettre du code** - Ajoutez des fonctionnalités ou corrigez des bugs
5. **Tester** - Testez les nouvelles versions et donnez votre retour

## Rapporter un Bug

Avant de créer une issue :
1. Vérifiez qu'une issue similaire n'existe pas déjà
2. Consultez le [guide de dépannage](TROUBLESHOOTING.md)
3. Testez avec la dernière version

Incluez dans votre rapport :
- Version de NixOS
- Architecture système
- Environnement de bureau utilisé
- Configuration pertinente
- Logs ou messages d'erreur
- Étapes pour reproduire le problème

## Suggérer une Fonctionnalité

Avant de suggérer :
1. Vérifiez que ça n'existe pas déjà
2. Consultez les issues existantes
3. Assurez-vous que c'est pertinent pour un environnement enfant

Dans votre suggestion, précisez :
- Le besoin ou problème à résoudre
- La solution proposée
- Les alternatives envisagées
- L'âge cible des enfants
- La disponibilité en français

## Soumettre du Code

### Prérequis

- Connaissance de Nix et NixOS
- Accès à une machine NixOS pour tester
- Compte GitHub

### Processus

1. **Fork le repository**
   ```bash
   # Via l'interface GitHub
   ```

2. **Clonez votre fork**
   ```bash
   git clone https://github.com/VOTRE-USERNAME/nixos-kid.git
   cd nixos-kid
   ```

3. **Créez une branche**
   ```bash
   git checkout -b feature/ma-nouvelle-fonctionnalite
   # ou
   git checkout -b fix/correction-bug
   ```

4. **Faites vos modifications**
   - Suivez les conventions du projet
   - Testez vos changements
   - Documentez le code si nécessaire

5. **Testez votre code**
   ```bash
   # Vérifiez la syntaxe
   nix flake check --no-build

   # Testez sur un système réel
   sudo nixos-rebuild test --flake .#
   ```

6. **Committez vos changements**
   ```bash
   git add .
   git commit -m "feat: ajoute telle fonctionnalité"
   # ou
   git commit -m "fix: corrige tel bug"
   ```

7. **Poussez vers votre fork**
   ```bash
   git push origin feature/ma-nouvelle-fonctionnalite
   ```

8. **Créez une Pull Request**
   - Via l'interface GitHub
   - Décrivez clairement les changements
   - Référencez les issues liées

### Conventions de Code

#### Style Nix
```nix
# Utilisez 2 espaces pour l'indentation
{
  option = {
    enable = mkEnableOption "Description";

    value = mkOption {
      type = types.str;
      default = "valeur";
      description = "Description de l'option";
    };
  };
}

# Commentaires en français
# Noms de variables en anglais (convention Nix)
```

#### Messages de Commit

Suivez la convention [Conventional Commits](https://www.conventionalcommits.org/) :

```
feat: ajoute support de KDE Plasma
fix: corrige le clavier AZERTY
docs: met à jour le README
refactor: restructure le module games
test: ajoute tests pour le module parental
chore: met à jour les dépendances
```

Exemples :
```
feat(education): ajoute l'application Scratch
fix(parental): corrige le filtrage DNS
docs(apps): ajoute description de GCompris
```

### Ajout d'Applications

#### Applications Éducatives

Critères :
- Appropriée pour des enfants (vérifier l'âge recommandé)
- Disponible en français (ou multilingue avec support FR)
- Open source de préférence
- Stable et maintenue
- Disponible dans nixpkgs

Processus :
1. Ajoutez l'option dans `modules/education.nix`
2. Documentez dans `APPLICATIONS.md`
3. Testez l'installation
4. Vérifiez que l'interface est bien en français

Exemple :
```nix
scratch = mkOption {
  type = types.bool;
  default = false;
  description = "Scratch - Programmation visuelle pour enfants";
};

# Plus loin dans le fichier
(optional cfg.scratch scratch)
```

#### Jeux

Mêmes critères, mais ajoutez dans `modules/games.nix`

Assurez-vous que le jeu :
- N'a pas de contenu violent/inapproprié
- Est adapté à l'âge cible (mentionner dans la doc)
- Fonctionne bien sur NixOS
- Est amusant ! (testez-le)

### Tests

Avant de soumettre :

```bash
# Syntaxe
nix flake check

# Test sur votre système
sudo nixos-rebuild test --flake .#

# Testez les fonctionnalités spécifiques
# - Lancez les applications ajoutées
# - Vérifiez qu'elles sont en français
# - Testez les contrôles parentaux si modifiés
```

### Documentation

Mettez à jour :
- `README.md` si nécessaire
- `APPLICATIONS.md` pour toute nouvelle application
- `CHANGELOG.md` avec vos modifications
- Commentaires dans le code

## Revue de Code

Votre Pull Request sera examinée pour :
- Qualité du code
- Respect des conventions
- Tests effectués
- Documentation
- Pertinence pour le projet

Soyez patient, les reviews peuvent prendre du temps.

## Code de Conduite

### Notre engagement

Ce projet vise à créer un environnement sûr et éducatif pour les enfants. Nous attendons de tous les contributeurs qu'ils :

- Soient respectueux et bienveillants
- Acceptent les critiques constructives
- Se concentrent sur ce qui est mieux pour les enfants
- Font preuve d'empathie envers les autres contributeurs

### Comportements acceptables

- Langage respectueux et inclusif
- Accepter les différents points de vue
- Critique constructive du code, pas des personnes
- Focus sur l'intérêt des enfants utilisateurs

### Comportements inacceptables

- Contenu inapproprié pour un projet destiné aux enfants
- Harcèlement sous toute forme
- Trolling ou commentaires insultants
- Toute autre conduite inappropriée

## Questions ?

Si vous avez des questions :
- Consultez la [documentation](README.md)
- Lisez les [issues existantes](https://github.com/VOTRE-REPO/nixos-kid/issues)
- Créez une nouvelle issue avec le tag "question"

## Remerciements

Merci à tous les contributeurs qui aident à rendre NixOS plus accessible aux enfants !

## Licence

En contribuant, vous acceptez que vos contributions soient sous licence MIT, comme le reste du projet.
