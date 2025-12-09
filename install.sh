#!/usr/bin/env bash
# Script d'installation de NixOS Kid-Friendly
# Usage: ./install.sh [nom-utilisateur]

set -euo pipefail

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions d'affichage
info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Vérifier qu'on est sur NixOS
if [ ! -f /etc/NIXOS ]; then
    error "Ce script doit être exécuté sur NixOS"
    exit 1
fi

# Vérifier qu'on est root
if [ "$EUID" -ne 0 ]; then
    error "Ce script doit être exécuté en tant que root"
    echo "Usage: sudo ./install.sh [nom-utilisateur]"
    exit 1
fi

# Récupérer le nom d'utilisateur
USERNAME="${1:-enfant}"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║        NixOS Kid-Friendly - Installation               ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

info "Configuration pour l'utilisateur: ${USERNAME}"
echo ""

# Demander confirmation
read -p "Voulez-vous continuer ? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
    warning "Installation annulée"
    exit 0
fi

# Créer un backup de la configuration actuelle
info "Sauvegarde de la configuration actuelle..."
BACKUP_DIR="/etc/nixos/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r /etc/nixos/* "$BACKUP_DIR/" 2>/dev/null || true
success "Backup créé dans $BACKUP_DIR"

# Vérifier si flakes est activé
info "Vérification de la configuration Flakes..."
if ! nix flake --version &>/dev/null; then
    warning "Flakes n'est pas activé. Activation..."
    cat >> /etc/nixos/configuration.nix <<EOF

# Activation des Flakes
nix.settings.experimental-features = [ "nix-command" "flakes" ];
EOF
    info "Reconstruction nécessaire pour activer Flakes..."
    nixos-rebuild switch
    success "Flakes activé"
fi

# Copier les modules dans /etc/nixos/
info "Installation des modules kid-friendly..."
mkdir -p /etc/nixos/modules/kid-friendly
cp -r modules/* /etc/nixos/modules/kid-friendly/
success "Modules installés"

# Créer un exemple de configuration
info "Création de la configuration d'exemple..."
cat > /etc/nixos/kid-friendly-example.nix <<EOF
# Configuration NixOS Kid-Friendly
# Généré automatiquement par install.sh
#
# Pour l'utiliser, ajoutez ceci dans votre configuration.nix:
#   imports = [ ./kid-friendly-example.nix ];

{ config, pkgs, ... }:

{
  # Import des modules
  imports = [
    ./modules/kid-friendly/kid-friendly.nix
  ];

  # Configuration kid-friendly
  kid-friendly = {
    enable = true;
    username = "${USERNAME}";
    fullName = "Enfant";
    autoLogin = true;
    desktopEnvironment = "gnome";

    education = {
      enable = true;
      gcompris = true;
      tuxpaint = true;
      childsplay = true;
      tuxtyping = true;
      kturtle = true;
      gbrainy = true;
    };

    games = {
      enable = true;
      supertux = true;
      supertuxkart = true;
      frozenBubble = true;
      minetest = true;
    };

    parental = {
      enable = true;
      blockAdultContent = true;
      disableRoot = true;
      safeBrowser = true;
      # Décommentez pour activer:
      # screenTimeLimit = "2h";
      # timeRestrictions = true;
      # restrictedHours = [ "20:00-08:00" ];
    };
  };
}
EOF
success "Configuration d'exemple créée: /etc/nixos/kid-friendly-example.nix"

# Instructions finales
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              Installation terminée !                   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
info "Prochaines étapes:"
echo ""
echo "1. Éditez votre /etc/nixos/configuration.nix et ajoutez:"
echo "   ${YELLOW}imports = [ ./kid-friendly-example.nix ];${NC}"
echo ""
echo "2. Ou copiez manuellement la configuration depuis:"
echo "   ${YELLOW}/etc/nixos/kid-friendly-example.nix${NC}"
echo ""
echo "3. Personnalisez les options selon vos besoins"
echo ""
echo "4. Reconstruisez le système:"
echo "   ${YELLOW}sudo nixos-rebuild switch${NC}"
echo ""
echo "5. Changez le mot de passe de l'utilisateur ${USERNAME}:"
echo "   ${YELLOW}sudo passwd ${USERNAME}${NC}"
echo ""
success "Documentation disponible dans:"
echo "   - README.md"
echo "   - APPLICATIONS.md (liste des applications)"
echo "   - TROUBLESHOOTING.md (résolution de problèmes)"
echo ""
info "Le mot de passe par défaut est: ${YELLOW}changeme${NC}"
warning "Pensez à le changer dès la première connexion !"
echo ""
