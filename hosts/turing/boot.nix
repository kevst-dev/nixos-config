_: {
  # Configuración de boot (UEFI con systemd-boot)
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Permitir que Podman rootless use puertos < 1024 (necesario para Traefik
    # y para Pi-hole, que sirve DNS en el puerto 53).
    kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 53;
  };
}
