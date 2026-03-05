{
  hostname,
  ip,
  ...
}: let
  tanenbaumNetworking = import ../../modules/common/networking.nix {
    interface = "eno1"; # Interfaz física del equipo según `ip a`
    firewallPorts = [22];
    inherit ip hostname;
  };
in {
  imports =
    [
      ../../modules/common/system.nix
      ../../modules/common/nix-ld.nix
      ../../modules/common/podman.nix
      ./hardware-configuration.nix
      ./boot.nix
    ]
    ++ [tanenbaumNetworking]
    ++ [
      ./users.nix
      ./server_ssh.nix
    ];

  # Tanenbaum se comporta como escritorio y servidor ligero; mantiene el stack de usuario pero
  # incorpora podman rootless y hardening de SSH.
  i18n.defaultLocale = "es_MX.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CO.UTF-8";
    LC_IDENTIFICATION = "es_CO.UTF-8";
    LC_MEASUREMENT = "es_CO.UTF-8";
    LC_MONETARY = "es_CO.UTF-8";
    LC_NAME = "es_CO.UTF-8";
    LC_NUMERIC = "es_CO.UTF-8";
    LC_PAPER = "es_CO.UTF-8";
    LC_TELEPHONE = "es_CO.UTF-8";
    LC_TIME = "es_CO.UTF-8";
  };

  time.timeZone = "America/Bogota";

  networking.networkmanager.enable = true;

  system.stateVersion = "25.11";
}
