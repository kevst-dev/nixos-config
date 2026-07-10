{
  config,
  pkgs,
  ...
}: {
  # Configuración de Television usando symlinks al repo
  home = {
    packages = with pkgs; [
      television
      tldr # requerido por el canal custom tldr
    ];

    # Toda la carpeta de configuración (config.toml + canales custom en cable/)
    file.".config/television" = {
      source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixos-config/dotfiles/television";
      force = true; # Sobrescribe el directorio existente (ya respaldado en dotfiles/)
    };
  };
}
