{hostname, ...}: {
  imports = [
    ../../modules/common/system.nix
    ../../modules/common/nix-ld.nix
    ./hardware-configuration.nix
    ./users.nix
    ./ssh.nix
    ./boot.nix
  ];

  networking = {
    hostName = hostname;
    useDHCP = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22];
  };

  system.stateVersion = "25.11";
}
