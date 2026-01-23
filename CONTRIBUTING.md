# Contributing to nixos-kid

Thank you for considering contributing to nixos-kid! This document provides guidelines and instructions for contributing.

## 🚀 Getting Started

### Prerequisites

- NixOS or Nix with flakes enabled
- Basic understanding of Nix language and NixOS modules
- `sops` for testing secrets management

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/likarum/nixos-kid.git
   cd nixos-kid
   ```

2. **Enable flakes** (if not already enabled)
   ```bash
   # Add to /etc/nixos/configuration.nix or ~/.config/nix/nix.conf
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

3. **Run automated tests**
   ```bash
   nix flake check
   ```

4. **Format code**
   ```bash
   nix fmt
   ```

## 📝 Code Style

### Nix Code

- Use explicit `lib.` prefix instead of `with lib;`
- Use `lib.mkEnableOption`, `lib.mkOption`, etc. explicitly
- Add descriptive comments for complex logic
- Keep lines under 100 characters when possible

**Example:**
```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.kidFriendly.myModule;
in
{
  options.kidFriendly.myModule = {
    enable = lib.mkEnableOption "My awesome module";

    myOption = lib.mkOption {
      type = lib.types.str;
      default = "default-value";
      example = "example-value";
      description = "What this option does";
    };
  };

  config = lib.mkIf cfg.enable {
    # Your configuration here
  };
}
```

### Documentation

- All options must have a `description`
- Complex options should have an `example`
- Update README.md for user-facing changes
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/)

### Commit Messages

Use conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(firewall): add proxy/VPN blocking option

Add blockProxiesAndVPN option to block common proxy and VPN ports,
preventing DNS filter bypass attempts.

Closes #42
```

```
fix(sops): make secretsFile path configurable

Remove hardcoded /etc/nixos/nixos-kid path and make it a required
option with example value.

Breaking change: Users must now set kidFriendly.sops.secretsFile
```

## 🧪 Testing

### Running Tests

```bash
# Run all checks (includes tests)
nix flake check

# Build specific test
nix build .#checks.x86_64-linux.integration

# Run tests in VM
nix build .#checks.x86_64-linux.integration -L
```

### Adding Tests

Tests are located in `tests/default.nix`. When adding a new feature:

1. Add test case to `testScript` in `tests/default.nix`
2. Ensure test validates the feature works correctly
3. Run `nix flake check` to verify

Example test:
```python
# Test that new firewall rule is active
print("[TEST] Checking my new rule...")
machine.succeed("iptables -L OUTPUT -n | grep -q 'my-rule'")
```

## 🔧 Adding a New Module

1. **Create the module file**
   ```bash
   touch modules/my-new-module.nix
   ```

2. **Write the module** (see Code Style above)

3. **Export in flake.nix**
   ```nix
   nixosModules = {
     # ... existing modules ...
     my-new-module = import ./modules/my-new-module.nix;

     default = {
       imports = [
         # ... existing imports ...
         self.nixosModules.my-new-module
       ];
     };
   };
   ```

4. **Add tests** in `tests/default.nix`

5. **Document** in README.md

6. **Update CHANGELOG.md**

## 🐛 Reporting Bugs

When reporting bugs, please include:

- NixOS version: `nixos-version`
- Flake inputs: `nix flake metadata`
- Minimal reproduction steps
- Expected vs actual behavior
- Relevant logs (AdGuard Home, systemd, firewall, etc.)

## 💡 Feature Requests

Feature requests are welcome! Please:

1. Check existing issues first
2. Explain the use case
3. Describe the proposed solution
4. Consider security implications for kid-friendly context

## 🔐 Security Considerations

This project is designed for parental control. When contributing:

- **Never** weaken existing protections without explicit opt-in
- **Always** consider bypass scenarios (proxies, DNS tunneling, etc.)
- **Test** that restrictions actually work
- **Document** any limitations or bypass methods
- **Remember** technical controls should complement trust and communication

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## ❓ Questions?

- Open an issue for technical questions
- Tag maintainers in your PR for review
- Be patient - this is maintained in free time

## 🙏 Code of Conduct

Be respectful, constructive, and professional. We're all here to create better tools for families.
