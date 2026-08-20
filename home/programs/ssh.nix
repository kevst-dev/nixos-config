{
  username,
  hosts,
  ...
}: let
  # Hosts que tienen IP estática definida en hosts.nix (se generan como alias SSH)
  hostNames = builtins.filter (name: hosts.${name}.ip != null) (builtins.attrNames hosts);
in {
  # =============================================================================
  # SSH Client - Configuración para conectarse a servicios y hosts
  # =============================================================================
  home.file."/home/${username}/.ssh/config".text = ''
    # GitHub
    Host github.com
      HostName github.com
      IdentityFile ~/.ssh/github_personal_ed25519
      IdentitiesOnly yes

    # Gitea Turing
    Host gitea-turing
      HostName gitea.kevst-turing.duckdns.org
      Port 222
      User git
      IdentityFile ~/.ssh/gitea_turing_ed25519
      IdentitiesOnly yes

    # Hosts personales (generados automáticamente desde hosts.nix)
    ${builtins.concatStringsSep "\n\n" (map (name: ''
        Host ${name}
          HostName ${hosts.${name}.ip}
          User ${hosts.${name}.username}
      '')
      hostNames)}
  '';
}
