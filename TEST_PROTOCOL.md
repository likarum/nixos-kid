# Test Protocol for v2.0.0 PR

This document describes the complete test protocol to validate the v2.0.0 changes before merging the PR.

**IMPORTANT:** These tests must be run on a NixOS machine with flakes enabled.

## 📋 Pre-Test Checklist

- [ ] NixOS machine with flakes enabled
- [ ] `sops` installed: `nix-shell -p sops`
- [ ] `ssh-to-age` installed: `nix-shell -p ssh-to-age`
- [ ] SSH host key exists at `/etc/ssh/ssh_host_ed25519_key.pub`

## 🧪 Test Suite

### Phase 1: Syntax and Build Validation

#### Test 1.1: Flake Lock Generation
```bash
cd /path/to/nixos-kid
nix flake lock
```

**Expected result:**
- `flake.lock` file created
- No errors
- File contains locked versions of `nixpkgs` and `sops-nix`

**Validation:**
```bash
ls -la flake.lock  # Should exist
cat flake.lock | grep -E "nixpkgs|sops-nix"  # Should contain both inputs
```

#### Test 1.2: Flake Check (Syntax)
```bash
nix flake check
```

**Expected result:**
- All syntax checks pass
- Build check passes
- No errors about missing options or type mismatches

**Common errors to watch for:**
- `attribute 'adminPasswordHash' missing` - GOOD (we removed it)
- `infinite recursion` - BAD (circular dependency)
- `undefined variable` - BAD (typo in lib.* calls)

#### Test 1.3: Flake Show (Outputs)
```bash
nix flake show
```

**Expected outputs:**
```
nixosModules
├───adguard-home
├───browser-policies
├───default
├───dns-enforcement
├───firewall
├───services-blocklist
└───sops
formatter
├───aarch64-linux
└───x86_64-linux
checks
├───aarch64-linux
│   └───build-minimal
└───x86_64-linux
    └───build-minimal
```

#### Test 1.4: Code Formatting
```bash
nix fmt
```

**Expected result:**
- All `.nix` files formatted
- No changes needed (code already formatted)

**Validation:**
```bash
git diff  # Should show no changes if already formatted
```

### Phase 2: SOPS Configuration Testing

#### Test 2.1: Setup Script Execution
```bash
./setup.sh
```

**Manual interaction required:**
- Enter AdGuard admin password when prompted

**Expected result:**
- `.sops.yaml` updated with age key (if it had placeholder)
- `secrets.yaml` created and encrypted
- Script reports "✅ Setup complete!"

**Validation:**
```bash
# Check .sops.yaml contains age key (not placeholder)
grep -v "YOUR_SSH_HOST_KEY" .sops.yaml

# Check secrets.yaml is encrypted (contains ENC[])
grep "ENC\[" secrets.yaml

# Test decryption works
sops -d secrets.yaml
```

#### Test 2.2: SOPS Secrets Required (Breaking Change)
Create a test configuration WITHOUT setting secretsFile:

```bash
cat > /tmp/test-no-sops.nix <<'EOF'
{ pkgs, ... }: {
  imports = [ ./flake.nix ];

  kidFriendly.adguardHome.enable = true;

  boot.loader.grub.device = "nodev";
  fileSystems."/" = { device = "/dev/null"; fsType = "ext4"; };
}
EOF

nix-instantiate --eval -E '(import <nixpkgs/nixos> { configuration = /tmp/test-no-sops.nix; }).config.system.build.toplevel'
```

**Expected result:**
- Build FAILS with error about SOPS being required
- Error message: `kidFriendly.sops.enable must be true when using adguardHome`

#### Test 2.3: Old adminPasswordHash Option Removed
Create a test configuration trying to use old option:

```bash
cat > /tmp/test-old-option.nix <<'EOF'
{ ... }: {
  kidFriendly.adguardHome = {
    enable = true;
    adminPasswordHash = "$2y$10$test";  # Old option
  };
}
EOF
```

Try to evaluate:
```bash
nix-instantiate --eval -E 'let cfg = import /tmp/test-old-option.nix { }; in cfg.kidFriendly.adguardHome.adminPasswordHash'
```

**Expected result:**
- Error: `attribute 'adminPasswordHash' missing`
- This confirms the option was removed

### Phase 3: Module Functionality Testing

#### Test 3.1: Firewall Module - Proxy/VPN Blocking
```bash
# Build minimal config with firewall
nix build .#checks.x86_64-linux.build-minimal -L
```

Check the generated firewall rules:
```bash
# Extract firewall rules from built config
nix-instantiate --eval --strict -E '
  (import <nixpkgs/nixos> {
    configuration = {
      imports = [ ./flake.nix ];
      kidFriendly = {
        sops.secretsFile = ./secrets.yaml;
        firewall = {
          enable = true;
          blockProxiesAndVPN = true;
        };
      };
      boot.loader.grub.device = "nodev";
      fileSystems."/" = { device = "/dev/null"; fsType = "ext4"; };
    };
  }).config.networking.firewall.extraCommands
' | grep -E "1080|8080|3128|9050|1194|51820|1723"
```

**Expected result:**
- Rules blocking ports: 1080 (SOCKS), 8080 (HTTP proxy), 3128 (Squid), 9050 (Tor), 1194 (OpenVPN), 51820 (WireGuard), 1723 (PPTP)

#### Test 3.2: All Modules Build Together
```bash
nix build .#checks.x86_64-linux.build-minimal --show-trace
```

**Expected result:**
- Build succeeds
- All modules load without conflicts
- SOPS is enabled by default

**Validation:**
Check that SOPS is enabled by default:
```bash
nix-instantiate --eval --strict -E '
  (import <nixpkgs/nixos> {
    configuration = { imports = [ ./flake.nix ]; };
  }).config.kidFriendly.sops.enable
'
# Should output: true
```

### Phase 4: Integration Tests

#### Test 4.1: Run VM Integration Tests
```bash
# This will take 5-10 minutes
nix build .#checks.x86_64-linux.integration -L
```

**Expected result:**
- VM boots successfully
- All services start (adguardhome, firewall rules, etc.)
- All 12 test assertions pass:
  1. AdGuard Home service running
  2. DNS port 53 open
  3. Web interface port 3000 open
  4. DNS resolution works
  5. /etc/resolv.conf correct
  6. Firewall rules active
  7. DoH providers blocked
  8. Proxy/VPN ports blocked
  9. Browser policies deployed
  10. Firefox DoH disabled
  11. AdGuard config exists
  12. Validation services OK

**If test fails, check:**
```bash
# See test output
nix log /nix/store/...-vm-test-nixos-kid-integration
```

### Phase 5: Documentation Validation

#### Test 5.1: README Examples Valid
Extract and test the minimal flake example from README:

```bash
# Extract example from README (lines 126-150)
sed -n '126,150p' README.md > /tmp/test-readme-example.nix

# Validate syntax
nix-instantiate --parse /tmp/test-readme-example.nix
```

**Expected result:**
- No syntax errors

#### Test 5.2: Example Flake Builds
```bash
# Test example-flake.nix is valid
nix-instantiate --parse example-flake.nix
```

**Expected result:**
- No syntax errors
- References to SOPS are present
- No references to old `adminPasswordHash` option

### Phase 6: Backwards Compatibility Breakage (Expected)

#### Test 6.1: Old Configuration Fails Gracefully
Create a v1.x style configuration:

```bash
cat > /tmp/test-v1-config.nix <<'EOF'
{ ... }: {
  imports = [ ./flake.nix ];

  kidFriendly.adguardHome = {
    enable = true;
    adminPasswordHash = "$2y$10$OldHashValue";
  };

  boot.loader.grub.device = "nodev";
  fileSystems."/" = { device = "/dev/null"; fsType = "ext4"; };
}
EOF

nix-build '<nixpkgs/nixos>' -A system -I nixos-config=/tmp/test-v1-config.nix 2>&1
```

**Expected result:**
- Build FAILS (this is correct - breaking change)
- Clear error message about SOPS being required or adminPasswordHash not existing

### Phase 7: Final Validation

#### Test 7.1: Git Status Clean
```bash
git status
```

**Expected result:**
- Only expected new/modified files staged
- No unexpected changes
- `flake.lock` exists and is tracked

#### Test 7.2: All New Files Present
```bash
ls -la | grep -E "setup.sh|CHANGELOG|CONTRIBUTING|.gitattributes"
ls -la tests/
```

**Expected files:**
- `setup.sh` (executable)
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `.gitattributes`
- `tests/default.nix`
- `flake.lock`

**Deleted files (should NOT exist):**
- `configuration.nix`
- `secrets.nix.example`

#### Test 7.3: Commit Messages Ready
```bash
git log --oneline -10
```

**Expected commits:** (will be created next)
- Should see feature branch commits with conventional format

## ✅ Success Criteria

All tests must pass:

- [ ] `nix flake check` succeeds
- [ ] `flake.lock` generated
- [ ] `setup.sh` runs successfully
- [ ] SOPS is mandatory (build fails without it)
- [ ] Old `adminPasswordHash` option removed
- [ ] Firewall proxy/VPN blocking present
- [ ] Integration tests pass (VM test)
- [ ] README examples are valid
- [ ] v1.x configs fail with clear error (breaking change)
- [ ] All new files present
- [ ] All obsolete files deleted

## 🚨 Failure Handling

If any test fails:

1. **Syntax errors:** Check for typos in `lib.` prefix usage
2. **SOPS errors:** Verify `.sops.yaml` and `secrets.yaml` are correct
3. **Module conflicts:** Check imports in `flake.nix`
4. **Test failures:** Check VM test logs for specific assertion failures

## 📝 Test Report Template

```markdown
# Test Report v2.0.0

**Tester:** [Your Name]
**Date:** [Date]
**NixOS Version:** [nixos-version output]
**Branch:** feat/v2-sops-mandatory-true-flake

## Test Results

- [ ] Phase 1: Syntax and Build ✅/❌
- [ ] Phase 2: SOPS Configuration ✅/❌
- [ ] Phase 3: Module Functionality ✅/❌
- [ ] Phase 4: Integration Tests ✅/❌
- [ ] Phase 5: Documentation ✅/❌
- [ ] Phase 6: Breaking Changes ✅/❌
- [ ] Phase 7: Final Validation ✅/❌

## Issues Found

[List any issues or unexpected behavior]

## Recommendation

- [ ] ✅ Ready to merge
- [ ] ❌ Needs fixes (see issues above)
```

---

**Next Step After Tests Pass:**
Generate `flake.lock` and commit all changes, then create the PR.
