{
  interface,
  ip,
  firewallPorts,
  hostname,
}: {
  networking = {
    hostName = hostname;

    # Config de red: DHCP si ip == null usara DHCP, si no sera
    # con ip estática
    useDHCP = ip == null;

    interfaces.${interface}.ipv4.addresses =
      if ip != null
      then [
        {
          address = ip;
          prefixLength = 24;
        }
      ]
      else [
        # empty
      ];

    # Configurar gateway y nameservers solo cuando se usa IP estática
    # Cuando ip != null (IP estática), se configuran valores fijos
    # Cuando ip == null (DHCP), se deja que DHCP asigne automáticamente
    # Esto evita conflictos en entornos como WSL donde la red es manejada por el host
    defaultGateway =
      if ip != null
      then "192.168.20.1"
      else null;
    # DNS: Usamos servidores públicos en lugar del router/módem porque:
    # - El DNS del módem puede ser lento, mal configurado o cambiar con hardware nuevo
    # - Cloudflare (1.1.1.1) y Google (8.8.8.8) son rápidos y confiables
    # - Hace la red más resiliente e independiente del ISP/módem
    # Nota: Antes usábamos "192.168.20.1" (DNS del router) pero causó problemas
    # al cambiar el módem - el nuevo tenía un resolver DNS deficiente
    nameservers =
      if ip != null
      then ["1.1.1.1" "8.8.8.8"]
      else [];

    firewall = {
      enable = true;
      allowedTCPPorts = firewallPorts;
    };
  };

  # systemd-resolved: Servicio de resolución DNS local que:
  # - Cachea consultas DNS (mejor rendimiento, menos tráfico)
  # - Maneja fallback automático si un servidor DNS falla
  # - Provee un stub resolver en 127.0.0.53
  # - Es más robusto que /etc/resolv.conf estático
  # Habilitado después de problemas con el cambio de módem (Feb 2026)
  services.resolved.enable = true;
}
