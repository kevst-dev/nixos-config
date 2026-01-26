{
  config,
  pkgs,
  ...
}: {
  # Configuración de OpenCode usando symlinks al repo
  home.packages = with pkgs; [opencode];

  home.file.".config/opencode/opencode.json".source =
    # Crea symlink fuera del store de Nix para editar en repo
    config.lib.file.mkOutOfStoreSymlink
    # Ruta al archivo en el directorio de dotfiles
    "${config.home.homeDirectory}/nixos-config/dotfiles/opencode/opencode.json";
}
