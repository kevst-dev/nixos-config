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
  networking = {
    hostName = "turing";

    # Configuración de red estática
    useDHCP = false;
    interfaces.enp2s0.ipv4.addresses = [
      {
        address = "192.168.20.79";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.20.1";
    nameservers = ["192.168.20.1"];

    # Configuración de firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];
    };
  };

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

  # Disco adicional para datos (servicios, contenedores)
  fileSystems."/mnt/nvme0n1" = {
    device = "/dev/disk/by-uuid/b7d7d1a4-e3e5-49e3-8b5d-de73a6281598";
    fsType = "ext4";
  };

  # Habilitar SSH para acceso remoto
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Habilitar Podman para contenedores
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Alias docker -> podman
    defaultNetwork.settings.dns_enabled = true;
  };

  # Paquetes para gestión de contenedores
  environment.systemPackages = with pkgs; [
    podman-compose # Soporte para docker-compose con Podman
  ];

  # stateVersion es la "Versión de Instalación Original" de NixOS
  # - Marca de tiempo de cuándo instalaste el sistema por primera vez
  # - NUNCA lo cambies (incluso si actualizas a versiones nuevas)
  # - Solo existe para compatibilidad con datos con estado
  # - Cambiarlo puede causar pérdida de datos
  system.stateVersion = "25.11"; # Turing es instalación nueva (2026-01)
}
