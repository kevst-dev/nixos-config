{
  pkgs,
  username,
  ...
}: {
  imports = [../../modules/common/system.nix];

  # Configuración específica del servidor Turing
  networking.hostName = "turing";

  # Configurar zsh como shell por defecto para el usuario
  users.users.${username}.shell = pkgs.zsh;

  # Habilitar SSH para acceso remoto
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Habilitar Podman para contenedores
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Alias docker -> podman
    defaultNetwork.settings.dns_enabled = true;
  };

  # Configuración de firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # SSH
      80 # HTTP
      443 # HTTPS
    ];
  };

  # Versión de NixOS para compatibilidad de datos con estado
  system.stateVersion = "25.05";
}
