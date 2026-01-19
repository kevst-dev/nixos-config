_: {
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
        80 # HTTP (Traefik)
        443 # HTTPS (Traefik)
        8080 # Traefik Dashboard
      ];
    };
  };
}
