{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.kidFriendly.browserPolicies;
in
{
  options.kidFriendly.browserPolicies = {
    enable = mkEnableOption "Applique les policies navigateurs anti-DoH";

    firefox.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Active les policies Firefox";
    };

    chromium.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Active les policies Chromium/Chrome";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = mkIf cfg.firefox.enable {
      enable = true;

      policies = {
        DNSOverHTTPS = {
          Enabled = false;
          Locked = true;
        };

        Preferences = {
          "network.trr.mode" = {
            Value = 5;
            Status = "locked";
          };

          "network.trr.uri" = {
            Value = "";
            Status = "locked";
          };

          "network.trr.bootstrapAddress" = {
            Value = "";
            Status = "locked";
          };

          "network.trr.excluded-domains" = {
            Value = "";
            Status = "locked";
          };

          "network.trr.disable-ECS" = {
            Value = false;
            Status = "locked";
          };
        };

        DisableFirefoxStudies = true;
        DisableTelemetry = true;
        DisablePocket = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxVpn = true;
      };

      preferencesStatus = "default";
    };

    programs.chromium = mkIf cfg.chromium.enable {
      enable = true;

      extraOpts = {
        DnsOverHttpsMode = "off";
        DnsOverHttpsTemplates = "";

        BuiltInDnsClientEnabled = false;

        NetworkPredictionOptions = 2;

        ForceGoogleSafeSearch = true;
        ForceYouTubeSafetyMode = true;

        SearchSuggestEnabled = false;
        MetricsReportingEnabled = false;

        AllowRunningInsecureContent = false;
        AutofillCreditCardEnabled = false;

        DefaultWebBluetoothGuardSetting = 2;
        DefaultWebUsbGuardSetting = 2;
        DefaultGeolocationSetting = 2;
        DefaultNotificationsSetting = 2;

        VideoCaptureAllowed = false;
        AudioCaptureAllowed = false;

        HttpsOnlyMode = "force_enabled";
      };
    };

    systemd.services.check-browser-policies = {
      description = "Vérifie que les policies navigateurs sont appliquées";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        echo "Checking browser policies..."

        ${if cfg.firefox.enable then ''
          if [ -f /run/current-system/sw/lib/firefox/distribution/policies.json ]; then
            echo "Firefox policies.json found"
            if grep -q '"Enabled": false' /run/current-system/sw/lib/firefox/distribution/policies.json 2>/dev/null; then
              echo "Firefox DoH disabled: OK"
            else
              echo "WARNING: Firefox DoH policy not found!"
            fi
          else
            echo "WARNING: Firefox policies.json not found!"
          fi
        '' else ""}

        ${if cfg.chromium.enable then ''
          if [ -d /etc/chromium/policies/managed ]; then
            echo "Chromium policies directory found"
            if grep -q '"DnsOverHttpsMode": "off"' /etc/chromium/policies/managed/*.json 2>/dev/null; then
              echo "Chromium DoH disabled: OK"
            else
              echo "WARNING: Chromium DoH policy not found!"
            fi
          fi
        '' else ""}

        echo "Browser policies check completed"
      '';
    };
  };
}
