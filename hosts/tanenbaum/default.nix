{hostname, ...}: {
  imports = [
    ../../modules/common/system.nix
    ../../modules/common/nix-ld.nix
    ./hardware-configuration.nix
    ./users.nix
    ./ssh.nix
    ./boot.nix
  ];

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

  networking = {
    networkmanager.enable = true;
    hostName = hostname;
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
    };
  };

  system.stateVersion = "25.11";
}
