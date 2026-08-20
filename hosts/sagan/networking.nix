{hostname, ...}: {
  # =========================================================================
  # Networking FASE 1: acceso básico vía SSH
  # =========================================================================
  # El M73 Tiny tiene una sola NIC onboard (Intel I217-V). En esta fase usa
  # DHCP contra el módem/router actual para quedar accesible por SSH.
  #
  # En FASE 2 se reemplaza este archivo: renombrado de interfaces por MAC
  # (wan0/lan0), NAT, firewall de router y DHCP/Kea para la LAN.
  # =========================================================================

  networking = {
    hostName = hostname;

    # Asigna DHCP a todas las interfaces. No dependemos del nombre de la NIC
    # (eno1/enp0s25/...) porque aún no conocemos el naming de udev del M73.
    useDHCP = true;

    # Firewall del host: solo SSH abierto por ahora.
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
    };
  };

  # systemd-resolved para resolución DNS local (igual que el resto de hosts)
  services.resolved.enable = true;
}
