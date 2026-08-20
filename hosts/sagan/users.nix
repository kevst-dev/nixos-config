{
  pkgs,
  username,
  ...
}: {
  # ───────────────────────────────────────────────────────────────────────────
  # CONFIGURACIÓN DEL USUARIO PARA SAGAN (ROUTER)
  # ───────────────────────────────────────────────────────────────────────────
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    group = username;
    extraGroups = [
      "wheel" # Permite usar sudo
      "networkmanager" # Permite gestionar redes
    ];
  };

  # Crear el grupo con el mismo nombre que el usuario
  users.groups.${username} = {};

  # zsh a nivel de sistema, requerido por Home Manager
  programs.zsh.enable = true;
}
