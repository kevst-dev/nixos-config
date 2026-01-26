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
    nameservers =
      if ip != null
      then ["192.168.20.1"]
      else [];

    firewall = {
      enable = true;
      allowedTCPPorts = firewallPorts;
    };
  };
}
