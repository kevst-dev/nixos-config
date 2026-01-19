{
  pkgs,
  username,
  ...
}: {
  # Configuración del usuario
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    group = username;
    extraGroups = ["wheel" "networkmanager"];
    linger = true; # Permite que servicios del usuario persistan después del logout/reboot
  };

  users.groups.${username} = {};
}
