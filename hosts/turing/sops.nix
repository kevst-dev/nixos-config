{username, ...}: {
  # =============================================================================
  # SOPS-Nix - Gestión de secretos (NixOS)
  # =============================================================================
  # Por defecto, sops-nix crea los secrets en /run/secrets/<nombre>
  # Por ejemplo: /run/secrets/restic_password
  sops = {
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    defaultSopsFile = ../../secrets/turing.yaml;

    secrets = {
      restic_password = {};
      github_personal_ssh_key = {
        path = "/home/${username}/.ssh/github_personal_ed25519";
        owner = username;
        group = username;
        mode = "0600";
      };
    };
  };
}
