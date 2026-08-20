{
  hostname,
  ip,
  ...
}: {
  # =========================================================================
  # Networking FASE 1: IP estática para acceso SSH sin pantalla/HDMI
  # =========================================================================
  # El M73 Tiny tiene una sola NIC onboard (Intel I217-V, `eno1`). Se le asigna
  # una IP estática dentro de la subred del módem para poder conectarnos por
  # SSH a una dirección fija, sin depender del DHCP (ni de pantalla/HDMI para
  # descubrir la IP). Gateway y DNS los pone el módulo común networking.nix.
  #
  # En FASE 2 se reemplaza: renombrado de interfaces por MAC (wan0/lan0), NAT,
  # firewall de router y DHCP/Kea para la LAN.
  # =========================================================================
  imports = [
    (import ../../modules/common/networking.nix {
      interface = "eno1";
      firewallPorts = [
        22 # SSH
      ];
      inherit hostname ip;
    })
  ];
}
