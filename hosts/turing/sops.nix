{ config, lib, ... }:
{
  # =============================================================================
  # SOPS-Nix - Gestión de secretos (NixOS)
  # =============================================================================
  # Por defecto, sops-nix crea los secrets en /run/secrets/<nombre>
  # Por ejemplo: /run/secrets/restic_password
  sops = {
    age.keyFile = "/home/kevst/.config/sops/age/keys.txt";

    defaultSopsFile = ../../secrets/turing.yaml;

    secrets.restic_password = {};
  };
}
