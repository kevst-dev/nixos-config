{username, ...}: {
  # =============================================================================
  # SSH Client - Configuración para conectarse a servicios externos
  # =============================================================================
  home.file."/home/${username}/.ssh/config".text = ''
    Host github.com
      HostName github.com
      IdentityFile ~/.ssh/github_personal_ed25519
      IdentitiesOnly yes
  '';
}
