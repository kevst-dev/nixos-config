_: {
  # Configuración de boot (UEFI con systemd-boot)
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Permitir que Podman rootless use puertos < 1024 (necesario para Traefik)
    kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
  };
}
