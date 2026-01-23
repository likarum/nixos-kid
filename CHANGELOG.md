# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-20

### 🚨 Breaking Changes

- **SOPS is now mandatory**: Removed support for plaintext password hash in configuration
  - `kidFriendly.adguardHome.adminPasswordHash` option has been removed
  - All secrets must now be managed through SOPS encryption
  - Migration required: see `setup.sh` or README for setup instructions

- **Flake is now properly locked**: Added `flake.lock` for reproducible builds
  - Previous installations may need to run `nix flake update` to refresh dependencies

- **Removed obsolete files**:
  - `secrets.nix.example` (plaintext mode, no longer supported)
  - `configuration.nix` (replaced by `flake-configuration.nix` with SOPS examples)

### ✨ Added

- **Automated setup script** (`setup.sh`)
  - Automatically converts SSH host key to age format
  - Generates encrypted `secrets.yaml` with user prompts
  - Validates SOPS configuration

- **Proxy and VPN blocking** (`kidFriendly.firewall.blockProxiesAndVPN`)
  - Blocks SOCKS proxy (port 1080)
  - Blocks HTTP/HTTPS proxies (ports 8080, 3128)
  - Blocks Tor (port 9050)
  - Blocks OpenVPN (port 1194)
  - Blocks WireGuard (port 51820)
  - Blocks PPTP VPN (port 1723)
  - Enabled by default

- **Integration tests** (`tests/default.nix`)
  - Automated testing with `nix flake check`
  - Tests AdGuard Home, DNS enforcement, firewall rules, browser policies
  - Validates all services start correctly

- **Flake enhancements**:
  - Added `formatter` output (nixpkgs-fmt)
  - Added `checks` output for automated testing
  - Multi-arch support (x86_64-linux, aarch64-linux)

- **Documentation**:
  - New `CHANGELOG.md` (this file)
  - New `CONTRIBUTING.md` with development guidelines
  - Updated `example-flake.nix` with comprehensive SOPS usage examples
  - `.gitattributes` to mark `flake.lock` as generated

### 🔧 Changed

- **Modernized Nix code style**:
  - Removed `with lib;` in favor of explicit `lib.` prefix
  - Better readability and maintenance

- **SOPS module improvements**:
  - `secretsFile` option is now required (no hardcoded default path)
  - Better error messages when SOPS is not configured
  - Enabled by default in the `default` module

- **AdGuard Home module**:
  - Strict assertions ensure SOPS is enabled
  - Clearer error messages for missing secrets

### 📝 Documentation

- Complete rewrite of README.md for v2.0
  - Removed all references to plaintext password mode
  - Simplified installation to 3 steps with `setup.sh`
  - Better structured with clear prerequisites
  - Updated examples to use SOPS exclusively

### 🔐 Security

- All secrets now encrypted at rest with SOPS/age
- SSH host key used for encryption (simpler than dedicated age keys)
- No plaintext secrets in configuration files
- Enhanced proxy/VPN blocking prevents DNS bypass attempts

### 🐛 Fixed

- Flake is now properly reproducible with `flake.lock`
- Better validation of SOPS configuration at build time
- Fixed potential issues with undefined `secretsFile` path

## [1.0.0] - 2026-01-19

Initial release with basic kid-friendly features:
- AdGuard Home DNS filtering
- DNS enforcement
- Browser policies (Firefox, Chromium)
- Firewall rules blocking DoH/DoT
- Services blocklist
- Optional SOPS support

[2.0.0]: https://github.com/likarum/nixos-kid/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/likarum/nixos-kid/releases/tag/v1.0.0
