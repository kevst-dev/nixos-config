{hostname, ...}: {
  imports = [
    ../../modules/common/system.nix
    ../../modules/common/nix-ld.nix
    ./hardware-configuration.nix
    ./users.nix
    ./ssh.nix
    ./boot.nix
    ./sops.nix
  ];

  # NixOS module para Hyprland (requerido para session files y XDG portals)
  # Referencia: https://wiki.hypr.land/Nix/
  programs.hyprland.enable = true;

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
