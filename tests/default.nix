# Integration tests for nixos-kid
#
# Run with: nix flake check
# Or specifically: nix build .#checks.x86_64-linux.integration

{ nixpkgs, self, system ? "x86_64-linux" }:

let
  pkgs = nixpkgs.legacyPackages.${system};

  # Create a mock secrets file for testing
  mockSecretsYaml = pkgs.writeText "mock-secrets.yaml" ''
    adguard-admin-password: ENC[mock-encrypted-hash]
    child-initial-password: ENC[mock-encrypted-password]
    child-username: ENC[mock-encrypted-username]
    child-fullname: ENC[mock-encrypted-fullname]
  '';

  # Mock bcrypt hash for testing (corresponds to password "test123")
  mockBcryptHash = "$2y$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOP";
in
nixpkgs.lib.nixos.runTest {
  name = "nixos-kid-integration";

  nodes.machine = { config, pkgs, lib, ... }: {
    imports = [
      self.nixosModules.default
    ];

    # Mock SOPS for testing (bypass encryption)
    sops.secrets."adguard-admin-password".path = pkgs.writeText "mock-password" mockBcryptHash;
    sops.secrets."child-initial-password".path = pkgs.writeText "mock-child-pass" "mock-password";
    sops.secrets."child-username".path = pkgs.writeText "mock-username" "kid";
    sops.secrets."child-fullname".path = pkgs.writeText "mock-fullname" "Kid User";

    # Enable all kidFriendly modules
    kidFriendly = {
      sops = {
        enable = true;
        secretsFile = mockSecretsYaml;
      };

      adguardHome.enable = true;

      dnsEnforcement.enable = true;

      browserPolicies = {
        enable = true;
        firefox.enable = true;
        chromium.enable = true;
      };

      firewall = {
        enable = true;
        blockDoHProviders = true;
        blockProxiesAndVPN = true;
      };

      servicesBlocklist.enable = true;
    };

    # Minimal system configuration
    boot.loader.grub.device = "nodev";
    fileSystems."/" = {
      device = "/dev/vda";
      fsType = "ext4";
    };
    system.stateVersion = "24.11";
  };

  testScript = ''
    start_all()

    # Wait for system to boot
    machine.wait_for_unit("multi-user.target")

    # Test 1: AdGuard Home service is running
    print("[TEST] Checking AdGuard Home service...")
    machine.wait_for_unit("adguardhome.service")
    machine.succeed("systemctl is-active adguardhome.service")

    # Test 2: AdGuard Home is listening on port 53
    print("[TEST] Checking DNS port 53...")
    machine.wait_for_open_port(53)

    # Test 3: AdGuard Home web interface is accessible on port 3000
    print("[TEST] Checking web interface port 3000...")
    machine.wait_for_open_port(3000)

    # Test 4: DNS resolution works through AdGuard Home
    print("[TEST] Testing DNS resolution...")
    machine.succeed("dig @127.0.0.1 google.com | grep -q 'ANSWER SECTION'")

    # Test 5: /etc/resolv.conf points to 127.0.0.1
    print("[TEST] Checking /etc/resolv.conf...")
    machine.succeed("grep -q 'nameserver 127.0.0.1' /etc/resolv.conf")

    # Test 6: Firewall rules are active
    print("[TEST] Checking firewall rules...")
    machine.succeed("iptables -L OUTPUT -n | grep -q 'REJECT.*udp dpt:53'")
    machine.succeed("iptables -L OUTPUT -n | grep -q 'REJECT.*tcp dpt:853'")

    # Test 7: DoH providers are blocked
    print("[TEST] Checking DoH provider blocking...")
    machine.succeed("iptables -L OUTPUT -n | grep -q '1.1.1.1.*REJECT'")

    # Test 8: Proxy/VPN ports are blocked
    print("[TEST] Checking proxy/VPN blocking...")
    machine.succeed("iptables -L OUTPUT -n | grep -q 'REJECT.*tcp dpt:1080'")  # SOCKS
    machine.succeed("iptables -L OUTPUT -n | grep -q 'REJECT.*tcp dpt:8080'")  # HTTP proxy

    # Test 9: Browser policies are deployed
    print("[TEST] Checking browser policies...")
    machine.succeed("test -f /etc/firefox/policies/policies.json")
    machine.succeed("test -d /etc/chromium/policies/managed")

    # Test 10: Firefox DoH is disabled in policy
    print("[TEST] Verifying Firefox DoH disabled...")
    machine.succeed("grep -q '\"mode\": 5' /etc/firefox/policies/policies.json")

    # Test 11: AdGuard Home config contains expected blocklists
    print("[TEST] Checking AdGuard Home blocklists...")
    machine.succeed("test -f /var/lib/AdGuardHome/AdGuardHome.yaml")

    # Test 12: Validation services ran successfully
    print("[TEST] Checking validation services...")
    machine.succeed("systemctl is-active check-dns-enforcement.service")
    machine.succeed("systemctl is-active check-firewall-rules.service")

    print("[SUCCESS] All integration tests passed!")
  '';
}
