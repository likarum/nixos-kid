# Configuration NixOS utilisant le flake nixos-kid
# Ce fichier doit être placé dans /etc/nixos/configuration.nix
# ou importé depuis votre configuration principale

{ config, pkgs, ... }:

{
  imports = [
    # Votre hardware-configuration.nix
    # ./hardware-configuration.nix
  ];

  # ===================================================================
  # CONFIGURATION KIDFRIENDLY
  # ===================================================================

  kidFriendly = {
    # SOPS secrets management
    sops.enable = true;

    # AdGuard Home (HTTP sur port 3000)
    adguardHome = {
      enable = true;
      # Le hash sera lu depuis config.sops.secrets.adguard-admin-password.path
    };

    # DNS enforcement
    dnsEnforcement.enable = true;

    # Browser policies
    browserPolicies = {
      enable = true;
      firefox.enable = true;
      chromium.enable = true;
    };

    # Firewall
    firewall = {
      enable = true;
      blockDoHProviders = true;
    };

    # Services blocklist (tout bloqué sauf Steam)
    servicesBlocklist = {
      enable = true;
      # Steam est autorisé par défaut (blockSteam = false)
      # Tous les autres services sont bloqués par défaut
    };
  };

  # ===================================================================
  # CONFIGURATION SYSTÈME
  # ===================================================================

  networking.hostName = "laptop-enfant";
  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  console.keyMap = "fr";

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb.layout = "fr";
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  networking.networkmanager.enable = true;

  # Compte admin parent (avec sudo)
  users.users.admin = {
    isNormalUser = true;
    description = "Parent Admin";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Compte enfant (SANS sudo - pas de groupe wheel)
  # Le nom d'utilisateur, description et mot de passe initial sont dans secrets.yaml (chiffrés avec sops)
  users.users.enfant = {
    isNormalUser = true;
    description = "Enfant"; # Peut être overridé avec sops
    extraGroups = [ "networkmanager" "video" "audio" ];
    # Le mot de passe initial sera défini via hashedPasswordFile
    hashedPasswordFile = config.sops.secrets."child-initial-password".path;

    packages = with pkgs; [
      firefox
      chromium
      gcompris
      tuxmath
      tuxpaint
      libreoffice
      kate
      vlc
    ];
  };

  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
    git
    dig
    apacheHttpd
    sops        # Pour éditer secrets.yaml
    ssh-to-age  # Pour convertir clé SSH en age
  ];

  system.stateVersion = "25.11";
}
