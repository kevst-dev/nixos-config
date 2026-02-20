{username, ...}: {
  # =============================================================================
  # SSH Client - Configuración para conectarse a servicios externos
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
  '';
}
