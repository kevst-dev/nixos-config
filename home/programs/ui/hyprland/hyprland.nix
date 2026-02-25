# Referencia: https://wiki.hypr.land/Nix/
{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.hyprland];

  # Home Manager module (opcional - mainly for PATH)
  # El NixOS module es el requerido (en hosts/stallman/default.nix)
  wayland.windowManager.hyprland = {
    enable = true;
  };

  # Symlink a dotfiles/hyprland/ para configuración tradicional
  home.file = {
    ".config/hypr" = {
      source = config.lib.file.mkOutOfStoreSymlink (
        config.home.homeDirectory + "/nixos-config/dotfiles/hyprland"
      );
      recursive = true;
    };
  };
}
