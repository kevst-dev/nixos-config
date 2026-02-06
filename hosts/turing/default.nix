{
  ip,
  hostname,
  ...
}: {
  imports = [
    ../../modules/common/system.nix
    ../../modules/common/nix-ld.nix
    ./hardware-configuration.nix

    # Herramientas a nivel de sistema
    ../../modules/common/podman.nix

    # Configuraciones específicas del host
    ./boot.nix
    # ./networking.nix
    (import ../../modules/common/networking.nix {
      interface = "enp2s0"; # Interfaz correcta para Turing
      # interface = "eth1";  # Interfaz correcta para Turing
      firewallPorts = [
        22 # SSH
        80 # HTTP (Traefik)
        443 # HTTPS (Traefik)
        8080 # Traefik Dashboard
      ];
      inherit ip hostname;
    })
    ./users.nix
    ./services.nix

    # Backups automáticos (restic)
    ./backup.nix
  ];

  # Configuración específica del servidor Turing

  # Disco adicional para datos (servicios, contenedores)
  fileSystems."/mnt/nvme0n1" = {
    device = "/dev/disk/by-uuid/b7d7d1a4-e3e5-49e3-8b5d-de73a6281598";
    fsType = "ext4";
  };

  # stateVersion es la "Versión de Instalación Original" de NixOS
  # - Marca de tiempo de cuándo instalaste el sistema por primera vez
  # - NUNCA lo cambies (incluso si actualizas a versiones nuevas)
  # - Solo existe para compatibilidad con datos con estado
  # - Cambiarlo puede causar pérdida de datos
  system.stateVersion = "25.11"; # Turing es instalación nueva (2026-01)
}
