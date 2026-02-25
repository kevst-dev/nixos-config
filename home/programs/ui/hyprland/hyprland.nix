# Referencia: https://wiki.hypr.land/Nix/
{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.hyprland];

  # NO usamos wayland.windowManager.hyprland de home-manager
  # para evitar conflicto con nuestros dotfiles

  # Symlink a dotfiles/hyprland/ usando home.file
  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/nixos-config/dotfiles/hyprland";
}
