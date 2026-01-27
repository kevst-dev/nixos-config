{
  hostname,
  ip,
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../modules/common/system.nix

    (import ../../modules/common/networking.nix {
      interface = "eth0";
      firewallPorts = [];
      inherit ip hostname;
    })
  ];

  # Configuración específica de WSL
  wsl.enable = true;
  wsl.defaultUser = username;

  # Configurar zsh como shell por defecto para el usuario
  users.users.${username}.shell = pkgs.zsh;

  # stateVersion es la "Versión de Instalación Original" de NixOS
  # - Marca de tiempo de cuándo instalaste el sistema por primera vez
  # - NUNCA lo cambies (incluso si actualizas a versiones nuevas)
  # - Solo existe para compatibilidad con datos con estado
  # - Cambiarlo puede causar pérdida de datos
  system.stateVersion = "25.05";
}
