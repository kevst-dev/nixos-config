{...}: {
  imports = [
    ../../modules/common/system.nix
    ../../modules/common/nix-ld.nix
    ./hardware-configuration.nix

    # Configuraciones específicas del host
    ./boot.nix
    ./networking.nix
    ./ssh.nix
    ./users.nix

    # SOPS-Nix para gestión de secretos
    ./sops.nix
  ];

  # stateVersion es la "Versión de Instalación Original" de NixOS
  # - Marca de tiempo de cuándo instalaste el sistema por primera vez
  # - NUNCA lo cambies (incluso si actualizas a versiones nuevas)
  # - Solo existe para compatibilidad con datos con estado
  # - Cambiarlo puede causar pérdida de datos
  system.stateVersion = "26.05"; # Sagan es instalación nueva (2026-08)
}
