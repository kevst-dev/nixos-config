{
  interface,
  ip,
  firewallPorts,
  hostname,
  # Habilita un servidor DNS local (por ejemplo Pi-hole) para la red local.
  #
  # ¿Qué hace exactamente?
  #   1. Abre el puerto 53 (UDP y TCP) en el firewall del host para que los
  #      dispositivos de la LAN puedan consultar el servidor DNS de Turing.
  #      Sin esto, el firewall de NixOS (que por defecto solo abre los puertos
  #      TCP de firewallPorts) bloquea las consultas DNS entrantes.
  #   2. Cuando es true, deja claro en la configuración que el host sirve DNS
  #      a la red local.
  #
  # ¿Cómo se usa? Cada host que importa este módulo puede pasar este flag:
  #   enableLocalDns = true;   # p.ej. en hosts/turing/default.nix
  # Por defecto es false, así que los demás hosts (wsl, stallman, tanenbaum)
  # NO abren el puerto 53 y no se ven afectados.
  #
  # Nota: este flag NO desactiva systemd-resolved. Solo controla el firewall.
  enableLocalDns ? false,
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

    # Firewall del host.
    # - allowedTCPPorts: puertos TCP permitidos (los básicos + los extra).
    #   Si enableLocalDns es true, se añade el 53/TCP (fallback de consultas DNS
    #   que no caben en un datagrama UDP).
    # - allowedUDPPorts: solo se abre el 53/UDP cuando enableLocalDns es true.
    #   Las consultas DNS de la red local viajan por UDP 53; sin abrirlo, los
    #   dispositivos de la LAN no pueden consultar a Pi-hole aunque esté corriendo.
    firewall = {
      enable = true;
      allowedTCPPorts =
        firewallPorts
        ++ (
          if enableLocalDns
          then [53]
          else []
        );
      allowedUDPPorts =
        if enableLocalDns
        then [53]
        else [];
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
