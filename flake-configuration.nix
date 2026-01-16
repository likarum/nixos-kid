# Configuration NixOS utilisant le flake nixos-kid
# Ce fichier doit être placé dans /etc/nixos/configuration.nix
# ou importé depuis votre configuration principale

{ config, pkgs, ... }:

let
  # Importer le fichier secrets (secrets.nix doit exister)
  secrets = import ./secrets.nix;
in
{
  imports = [
    # Votre hardware-configuration.nix
    # ./hardware-configuration.nix
  ];

  # ===================================================================
  # CONFIGURATION KIDFRIENDLY
  # ===================================================================

  kidFriendly = {
    # AdGuard Home
    adguardHome = {
      enable = true;
      adminPasswordHash = secrets.adguardAdminPasswordHash;
      lanSubnet = secrets.lanSubnet;
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
      lanSubnet = secrets.lanSubnet;
      blockDoHProviders = true;
    };

    # User
    user = {
      enable = true;
      username = secrets.childUsername;
      fullName = secrets.childFullName;
      initialPassword = secrets.childInitialPassword;
      extraGroups = [ "networkmanager" "video" "audio" ];

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

  users.users.admin = {
    isNormalUser = true;
    description = "Parent Admin";
    extraGroups = [ "wheel" "networkmanager" ];
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
  ];

  system.stateVersion = "24.05";
}
