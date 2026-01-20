#!/usr/bin/env bash
set -euo pipefail

echo "🔧 NixOS Kid-Friendly Setup"
echo "============================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}❌ Error: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo "ℹ️  $1"
}

# Step 1: Check if sops is installed
info "Checking for sops installation..."
if ! command -v sops &> /dev/null; then
    warning "sops not found. Installing temporarily..."
    if ! nix-shell -p sops --run "sops --version" &> /dev/null; then
        error "Failed to install sops. Please install it manually: nix-env -iA nixpkgs.sops"
    fi
    SOPS_CMD="nix-shell -p sops --run sops"
else
    success "sops is installed"
    SOPS_CMD="sops"
fi

# Step 2: Check if .sops.yaml is configured
info "Checking .sops.yaml configuration..."
if [ ! -f .sops.yaml ]; then
    error ".sops.yaml not found in current directory"
fi

if grep -q "YOUR_SSH_HOST_KEY" .sops.yaml; then
    warning ".sops.yaml contains placeholder key"

    # Check if ssh-to-age is available
    if ! command -v ssh-to-age &> /dev/null && ! nix-shell -p ssh-to-age --run "ssh-to-age --version" &> /dev/null; then
        error "ssh-to-age not available. Cannot convert SSH key automatically."
    fi

    # Convert SSH host key to age format
    if [ ! -f /etc/ssh/ssh_host_ed25519_key.pub ]; then
        error "SSH host key not found at /etc/ssh/ssh_host_ed25519_key.pub"
    fi

    info "Converting SSH host key to age format..."
    if command -v ssh-to-age &> /dev/null; then
        AGE_KEY=$(ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub)
    else
        AGE_KEY=$(nix-shell -p ssh-to-age --run 'ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub')
    fi

    if [ -z "$AGE_KEY" ]; then
        error "Failed to convert SSH key to age format"
    fi

    # Replace placeholder in .sops.yaml
    sed -i "s/YOUR_SSH_HOST_KEY/$AGE_KEY/" .sops.yaml
    success ".sops.yaml configured with SSH host key: ${AGE_KEY:0:20}..."
else
    success ".sops.yaml is already configured"
fi

# Step 3: Create secrets.yaml if it doesn't exist
if [ ! -f secrets.yaml ]; then
    info "Creating secrets.yaml from template..."

    if [ ! -f secrets.yaml.example ]; then
        error "secrets.yaml.example template not found"
    fi

    cp secrets.yaml.example secrets.yaml

    # Generate bcrypt password hash
    echo ""
    info "Generating bcrypt hash for AdGuard Home admin password..."

    if ! command -v mkpasswd &> /dev/null && ! command -v htpasswd &> /dev/null; then
        warning "Neither mkpasswd nor htpasswd found. You'll need to generate the hash manually."
        warning "Run: echo -n 'YourPassword' | mkpasswd -m bcrypt -s"
        warning "Then edit secrets.yaml with: $SOPS_CMD secrets.yaml"
    else
        read -sp "Enter AdGuard Home admin password: " ADMIN_PASS
        echo ""

        if command -v mkpasswd &> /dev/null; then
            HASH=$(echo -n "$ADMIN_PASS" | mkpasswd -m bcrypt -s)
        else
            HASH=$(htpasswd -nbB admin "$ADMIN_PASS" | cut -d: -f2)
        fi

        if [ -z "$HASH" ]; then
            error "Failed to generate bcrypt hash"
        fi

        # Create a temporary file to edit
        TEMP_SECRETS=$(mktemp)
        sed "s|YOUR_BCRYPT_HASH_HERE|$HASH|" secrets.yaml.example > "$TEMP_SECRETS"

        # Encrypt with sops
        info "Encrypting secrets.yaml with SOPS..."
        $SOPS_CMD -e "$TEMP_SECRETS" > secrets.yaml
        rm -f "$TEMP_SECRETS"

        success "secrets.yaml created and encrypted"
    fi
else
    success "secrets.yaml already exists"
fi

# Step 4: Validate secrets.yaml can be decrypted
info "Validating secrets.yaml can be decrypted..."
if $SOPS_CMD -d secrets.yaml > /dev/null 2>&1; then
    success "secrets.yaml is valid and can be decrypted"
else
    error "Failed to decrypt secrets.yaml. Check your SSH key configuration."
fi

echo ""
success "Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Edit secrets if needed: $SOPS_CMD secrets.yaml"
echo "   2. Import this flake in your NixOS configuration"
echo "   3. Set kidFriendly.sops.secretsFile = ./path/to/secrets.yaml"
echo "   4. Rebuild: sudo nixos-rebuild switch --flake .#"
echo ""
info "See README.md for detailed usage instructions"
