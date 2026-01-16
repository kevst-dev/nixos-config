{
  pkgs,
  username,
  ...
}: {
  imports = [../../modules/common/system.nix];

  # Configuración específica de WSL
  wsl.enable = true;
  networking.hostName = "wsl";
  wsl.defaultUser = username;

  # Configurar zsh como shell por defecto para el usuario
  users.users.${username}.shell = pkgs.zsh;

  # Habilitar Podman para contenedores, para poder
  # usar opencode porque el nixpkgs esta demasiado viejo
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Alias docker -> podman
    defaultNetwork.settings.dns_enabled = true;
  };

  # stateVersion es la "Versión de Instalación Original" de NixOS
  # - Marca de tiempo de cuándo instalaste el sistema por primera vez
  # - NUNCA lo cambies (incluso si actualizas a versiones nuevas)
  # - Solo existe para compatibilidad con datos con estado
  # - Cambiarlo puede causar pérdida de datos
  system.stateVersion = "25.05";
}
