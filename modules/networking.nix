{ config, lib, pkgs, ... }:

# WiFi passwords declared here are stored in the Nix store (world-readable).
# For secrets you'd rather not commit, prefer the sops-nix or agenix approach,
# or just let NetworkManager remember them interactively (it already persists
# connections across reboots under /etc/NetworkManager/system-connections/).
#
# ensureProfiles entries are idempotent: NM creates the profile once and never
# overwrites manual edits to it, so you can still nmtui-edit them later.

{
  networking = {
    hostName = "nixos";          # ← change to your liking

    networkmanager = {
      enable = true;

      # Declarative WiFi profiles ─ add as many blocks as you need.
      # Passwords here are plain-text in the Nix store; see note above.
      ensureProfiles = {
        environmentFiles = [ ];  # optional: load secrets from a file outside the store

        profiles = {
          # "HomeWiFi" = {
          #   connection = {
          #     id   = "HomeWiFi";
          #     type = "wifi";
          #   };
          #   wifi = {
          #     mode = "infrastructure";
          #     ssid = "HomeWiFi";
          #   };
          #   wifi-security = {
          #     auth-alg = "open";
          #     key-mgmt = "wpa-psk";
          #     psk      = "your-password-here";
          #   };
          #   ipv4.method = "auto";
          #   ipv6.method = "auto";
          # };
        };
      };
    };
  };

  # Make sure your user is in the networkmanager group (see users.nix).
}
