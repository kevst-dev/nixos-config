{
  pkgs,
  username,
  ...
}: let
  podmanUserServices = import ./podman-user-services.nix {inherit pkgs;};
in {
  security.unprivilegedUsernsClone = true;

  # Configuración del usuario
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    group = username;
    extraGroups = ["wheel" "networkmanager"];
    linger = true; # Permite que servicios del usuario persistan después del logout/reboot
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
    packages = with pkgs; [
      podman
      podman-compose
      slirp4netns
      fuse-overlayfs
      shadow
    ];
  };

  users.groups.${username} = {};

  systemd.user.services = podmanUserServices.systemd.user.services;
}
