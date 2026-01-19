# Configuration NixOS pour laptop enfant avec filtrage DNS AdGuard Home
# Ce fichier est un exemple à adapter selon vos besoins

{ config, pkgs, ... }:

{
  imports = [
    # Importez votre hardware-configuration.nix
    # ./hardware-configuration.nix

    # Si vous utilisez ce flake, les modules sont déjà importés via inputs.nixos-kid.nixosModules.default
    # Sinon, importez-les manuellement :
    # ./nixos-kid/modules/adguard-home.nix
    # ./nixos-kid/modules/dns-enforcement.nix
    # ./nixos-kid/modules/browser-policies.nix
    # ./nixos-kid/modules/firewall.nix
  ];

  # ===================================================================
  # CONFIGURATION KIDFRIENDLY
  # ===================================================================

  kidFriendly = {
    # AdGuard Home avec configuration immuable (HTTPS activé par défaut sur port 3000)
    adguardHome = {
      enable = true;
      # enableHTTPS = true; # Par défaut, active HTTPS avec certificat auto-signé

      # IMPORTANT: Remplacez par votre hash bcrypt
      # Générer avec: htpasswd -B -n -b admin VotreMotDePasse
      adminPasswordHash = "$2y$10$REPLACE_WITH_ACTUAL_HASH";
    };

    # Force le DNS local uniquement
    dnsEnforcement.enable = true;

    # Policies navigateurs anti-DoH
    browserPolicies = {
      enable = true;
      firefox.enable = true;
      chromium.enable = true;
    };

    # Firewall avec blocage DoH providers
    firewall = {
      enable = true;
      blockDoHProviders = true;
    };
  };

  # ===================================================================
  # CONFIGURATION SYSTÈME
  # ===================================================================

  # Nom du système
  networking.hostName = "laptop-enfant";

  # Fuseau horaire
  time.timeZone = "Europe/Paris";

  # Locale française
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

  # Clavier français
  console.keyMap = "fr";

  # Desktop Environment (exemple avec GNOME)
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb.layout = "fr";
  };

  # Audio avec PipeWire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # NetworkManager
  networking.networkmanager.enable = true;

  # Compte administrateur parent (avec sudo)
  users.users.admin = {
    isNormalUser = true;
    description = "Parent Admin";
    extraGroups = [ "wheel" "networkmanager" ];
    # Définir le mot de passe avec: sudo passwd admin
  };

  # Compte enfant (SANS sudo - pas de groupe wheel)
  users.users.enfant = {
    isNormalUser = true;
    description = "Mon Enfant";
    extraGroups = [ "networkmanager" "video" "audio" ];
    initialPassword = "changeme";  # À changer au premier login

    packages = with pkgs; [
      # Navigateurs (policies déjà appliquées)
      firefox
      chromium

      # Éducation
      gcompris
      tuxmath
      tuxpaint

      # Bureautique
      libreoffice
      kate

      # Multimédia
      vlc
    ];
  };

  # Sudo pour wheel uniquement
  security.sudo.wheelNeedsPassword = true;

  # Paquets système
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
    git
    dig
    apacheHttpd  # Pour htpasswd (génération hash bcrypt)
  ];

  # SSH pour admin à distance (optionnel)
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PermitRootLogin = "no";
  #     PasswordAuthentication = false;
  #   };
  # };

  # Mises à jour automatiques (optionnel)
  # system.autoUpgrade = {
  #   enable = true;
  #   allowReboot = false;
  # };

  # Version NixOS (à adapter)
  system.stateVersion = "25.11";
}
