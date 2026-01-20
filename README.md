# NixOS Kid-Friendly - Robust DNS Filtering

![Flake](https://img.shields.io/badge/nix-flake-blue?logo=nixos)
![Version](https://img.shields.io/badge/version-2.0.0-green)
![License](https://img.shields.io/badge/license-MIT-blue)

NixOS configuration flake for kid-friendly laptop with **local DNS filtering via AdGuard Home**, designed to be difficult to bypass.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║                           ⚠️  IMPORTANT DISCLAIMERS  ⚠️                       ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  🚫 NO WARRANTY                                                               ║
║  This project is provided "AS IS", WITHOUT WARRANTY OF ANY KIND.             ║
║  I take NO RESPONSIBILITY for its use, bugs, or any issues that may occur.   ║
║                                                                               ║
║  🧪 EXPERIMENTAL PROJECT                                                      ║
║  This project was created PRIMARILY to TEST Claude (Anthropic) capabilities  ║
║  in generating NixOS configurations. The main goal is AI EXPERIMENTATION,    ║
║  not necessarily producing an ultra-robust system (though I'll probably      ║
║  deploy it anyway).                                                           ║
║                                                                               ║
║  👨‍👩‍👧 PARENTAL CONTROLS ARE NOT INFALLIBLE                                      ║
║  Parental control mechanisms (DNS filtering, restrictions) are NOT           ║
║  INFALLIBLE. ACTIVE PARENTAL SUPERVISION remains ESSENTIAL.                  ║
║  Do NOT rely solely on technical tools.                                      ║
║                                                                               ║
║  🧠 PHILOSOPHICAL REFLECTION                                                  ║
║  If your child has the technical skills to read and understand this NixOS    ║
║  code, or to bypass this filtering system, they have probably reached a      ║
║  level of technical maturity that questions the relevance of technical       ║
║  parental controls themselves. At this point, dialogue and trust become      ║
║  more effective than technical restrictions.                                 ║
║                                                                               ║
║  ⚡ USE AT YOUR OWN RISK                                                      ║
║  YOU are RESPONSIBLE for the configuration and use of this system for your   ║
║  children. ALWAYS TEST in a test environment before real deployment.         ║
║                                                                               ║
║  📝 Generated with Claude AI - Use at your own risk                          ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 🎯 Features

- ✅ **Local DNS filtering**: AdGuard Home on `127.0.0.1:53`
- ✅ **Secure admin interface**: HTTPS on port 3000 (self-signed certificate)
- ✅ **DoH/DoT blocking**: Bypass via DNS-over-HTTPS or DNS-over-TLS impossible
- ✅ **Browser policies**: Firefox and Chromium locked anti-DoH
- ✅ **Strict firewall**: Blocks public DoH IPs (Cloudflare, Google, Quad9)
- ✅ **Proxy/VPN blocking**: NEW in v2.0 - blocks SOCKS, HTTP proxies, VPN ports
- ✅ **Services blocklist**: Social media, gaming platforms, streaming (except Steam)
- ✅ **Non-sudo user**: Child cannot modify system configuration
- ✅ **Encrypted secrets**: SOPS-nix with age encryption (MANDATORY in v2.0)
- ✅ **Automated tests**: Integration tests with `nix flake check`

## 🏗️ Architecture

```
Applications (Firefox, Chromium, etc.)
         │ DoH blocked by policies + firewall
         │ Proxies/VPN blocked by firewall
         ▼
AdGuard Home (127.0.0.1:53)
  - Forced SafeSearch
  - Blocklists (porn, gambling, malware)
  - Parental filtering
  - Service blocking (Facebook, TikTok, etc.)
         │ Bootstrap DNS (UDP port 53)
         ▼
Bootstrap DNS (94.140.14.14, 193.110.81.0)
         │ Upstream DNS queries (DoH via port 443)
         ▼
Allowed DNS Providers ONLY
  - AdGuard DNS (94.140.14.14)
  - DNS0.eu (193.110.81.0)
  - Mullvad DNS (194.242.2.2)
```

## 📦 Modules

| Module | Description |
|--------|-------------|
| [sops.nix](modules/sops.nix) | Secrets management with sops-nix (age) - **MANDATORY** |
| [adguard-home.nix](modules/adguard-home.nix) | AdGuard Home with immutable config |
| [dns-enforcement.nix](modules/dns-enforcement.nix) | Forces local DNS only |
| [browser-policies.nix](modules/browser-policies.nix) | Firefox/Chromium anti-DoH policies |
| [firewall.nix](modules/firewall.nix) | Firewall blocking DoH + proxies/VPN |
| [services-blocklist.nix](modules/services-blocklist.nix) | Service blocking (social media, gaming) |

## 🚀 Quick Start (3 steps)

### Prerequisites

- NixOS with flakes enabled
- `sops` installed (will be auto-installed by setup.sh if missing)

### 1. Clone and Setup

```bash
# Clone the repository
cd /etc/nixos
git clone https://github.com/likarum/nixos-kid.git
cd nixos-kid

# Run automated setup (configures SOPS, generates secrets)
./setup.sh
```

The setup script will:
- Convert your SSH host key to age format
- Configure `.sops.yaml` automatically
- Generate encrypted `secrets.yaml` with your passwords
- Validate the SOPS configuration

### 2. Create Your Flake Configuration

See [example-flake.nix](example-flake.nix) for a complete example, or use this minimal version:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-kid.url = "github:likarum/nixos-kid";
  };

  outputs = { nixpkgs, nixos-kid, ... }: {
    nixosConfigurations.laptop-enfant = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        nixos-kid.nixosModules.default
        {
          kidFriendly.sops.secretsFile = ./nixos-kid/secrets.yaml;
          kidFriendly.adguardHome.enable = true;
          kidFriendly.dnsEnforcement.enable = true;
          kidFriendly.browserPolicies.enable = true;
          kidFriendly.firewall.enable = true;
          kidFriendly.servicesBlocklist.enable = true;
        }
      ];
    };
  };
}
```

### 3. Build and Deploy

```bash
# Build the configuration
sudo nixos-rebuild switch --flake /etc/nixos#laptop-enfant
```

**Done!** 🎉 Your kid-friendly system is ready.

## 📝 Configuration Options

### AdGuard Home

```nix
kidFriendly.adguardHome = {
  enable = true;
  enableHTTPS = true;  # Self-signed cert for web interface (default)
  extraUserRules = [    # Add custom blocking rules
    "||example.com^"
  ];
};
```

Access web interface: `https://localhost:3000` (admin password from SOPS)

### DNS Enforcement

```nix
kidFriendly.dnsEnforcement.enable = true;
```

Forces all DNS queries to `127.0.0.1` (AdGuard Home).

### Browser Policies

```nix
kidFriendly.browserPolicies = {
  enable = true;
  firefox.enable = true;   # Disables DoH in Firefox
  chromium.enable = true;  # Disables DoH + forces SafeSearch in Chromium
};
```

### Firewall

```nix
kidFriendly.firewall = {
  enable = true;
  blockDoHProviders = true;     # Blocks Cloudflare, Google, Quad9 DoH
  blockProxiesAndVPN = true;    # NEW v2.0: Blocks SOCKS, proxies, VPN ports
};
```

### Services Blocklist

```nix
kidFriendly.servicesBlocklist = {
  enable = true;

  # All enabled by default except Steam:
  blockFacebook = true;
  blockInstagram = true;
  blockTwitter = true;
  blockTikTok = true;
  blockSnapchat = true;
  blockReddit = true;
  blockDiscord = true;
  blockTwitch = true;
  blockYouTube = true;
  blockNetflix = true;

  # Gaming platforms
  blockEpicGames = true;
  blockRiotGames = true;
  blockBlizzard = true;
  blockEA = true;
  blockUbisoft = true;
  blockGOG = true;

  # Games
  blockFortnite = true;
  blockRoblox = true;
  blockMinecraftUnofficial = true;

  # Steam is ALLOWED by default
  blockSteam = false;  # Set to true to block Steam
};
```

### SOPS Secrets

```nix
kidFriendly.sops = {
  enable = true;  # Enabled by default in v2.0
  secretsFile = ./nixos-kid/secrets.yaml;  # REQUIRED
};
```

Edit secrets: `sops secrets.yaml`

Required secrets:
- `adguard-admin-password`: bcrypt hash for AdGuard Home admin
- `child-initial-password`: password for child user
- `child-username`: child's username
- `child-fullname`: child's full name

## 🧪 Testing

### Manual Testing

After deployment, test that protections are active:

```bash
# 1. DNS resolves via 127.0.0.1
dig @127.0.0.1 google.com

# 2. DoH providers are blocked
ping 1.1.1.1  # Should fail

# 3. External DNS port 53 is blocked
dig @8.8.8.8 google.com  # Should fail

# 4. DoT port 853 is blocked
nmap -p 853 9.9.9.9  # Should show filtered

# 5. Proxy ports are blocked (v2.0)
nmap -p 1080,8080,3128 localhost  # Should show filtered

# 6. Browser DoH is disabled
# Open Firefox → about:config → network.trr.mode should be 5

# 7. AdGuard web interface accessible
curl -k https://localhost:3000  # Should return HTML
```

### Automated Tests

```bash
# Run all tests
nix flake check

# Run specific test
nix build .#checks.x86_64-linux.integration -L
```

## 🔧 Development

```bash
# Format code
nix fmt

# Run checks
nix flake check

# Show flake outputs
nix flake show
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## 📚 Advanced Topics

### Using GitHub Instead of Local Path

In your `/etc/nixos/flake.nix`:

```nix
inputs.nixos-kid.url = "github:likarum/nixos-kid";
# Or pin to specific version:
# inputs.nixos-kid.url = "github:likarum/nixos-kid/v2.0.0";
```

### Backup Your SOPS Key

**CRITICAL**: Backup your SSH host key securely!

```bash
# Backup the private key (KEEP SECURE!)
sudo cp /etc/ssh/ssh_host_ed25519_key /path/to/secure/backup/

# If you lose this key, you cannot decrypt secrets.yaml
```

### Customizing AdGuard Blocklists

Edit `modules/adguard-home.nix` to add/remove blocklists:

```nix
filters = [
  {
    enabled = true;
    url = "https://example.com/my-custom-blocklist.txt";
    name = "My Custom Blocklist";
    id = 9;
  }
];
```

### Troubleshooting

**AdGuard Home not starting:**
```bash
sudo journalctl -u adguardhome.service -f
```

**SOPS cannot decrypt secrets:**
```bash
# Check SSH key is correct
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub

# Test decryption manually
sops -d /etc/nixos/nixos-kid/secrets.yaml
```

**DNS not resolving:**
```bash
# Check /etc/resolv.conf
cat /etc/resolv.conf  # Should contain nameserver 127.0.0.1

# Check AdGuard Home status
sudo systemctl status adguardhome
```

**Firewall rules not active:**
```bash
# List firewall rules
sudo iptables -L OUTPUT -n -v

# Check validation service
sudo journalctl -u check-firewall-rules.service
```

## 📖 Resources

- [AdGuard Home Documentation](https://github.com/AdguardTeam/AdGuardHome/wiki)
- [SOPS-nix Documentation](https://github.com/Mic92/sops-nix)
- [NixOS Manual - Flakes](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake)
- [Age Encryption](https://github.com/FiloSottile/age)

## 🔄 Migrating from v1.x

v2.0 is a breaking change. SOPS is now mandatory:

1. Run `./setup.sh` to configure SOPS
2. Remove `adminPasswordHash` from your configuration
3. Update flake: `nix flake update`
4. Rebuild: `sudo nixos-rebuild switch --flake .#`

See [CHANGELOG.md](CHANGELOG.md) for full migration guide.

## 📜 License

MIT License - See [LICENSE](LICENSE)

## 🙏 Acknowledgments

- Created with [Claude](https://claude.ai) (Anthropic) as an AI experimentation project
- [AdGuard Team](https://adguard.com/) for AdGuard Home
- [Mic92](https://github.com/Mic92) for sops-nix
- [NixOS Community](https://nixos.org/)

## ⚠️ Final Reminder

Technical controls are a **complement**, not a replacement for:
- Trust and dialogue with your child
- Age-appropriate conversations about online safety
- Parental supervision and involvement

The best "parental control" is a healthy relationship and open communication.

---

**Made with Claude** 🤖 | [Report Issues](https://github.com/likarum/nixos-kid/issues) | [Contributing](CONTRIBUTING.md)
