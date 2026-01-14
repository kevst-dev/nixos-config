{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../modules/common/system.nix
    ./hardware-configuration.nix
  ];

  # Configuración específica del servidor Turing
  networking.hostName = "turing";

  # Configuración del usuario
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    group = username;
    extraGroups = ["wheel" "networkmanager"];
  };

  users.groups.${username} = {};

  # Configuración de boot (UEFI con systemd-boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # stateVersion es la "Versión de Instalación Original" de NixOS
  # - Marca de tiempo de cuándo instalaste el sistema por primera vez
  # - NUNCA lo cambies (incluso si actualizas a versiones nuevas)
  # - Solo existe para compatibilidad con datos con estado
  # - Cambiarlo puede causar pérdida de datos
  system.stateVersion = "25.11"; # Turing es instalación nueva (2026-01)
}
