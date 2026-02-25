# Referencia: https://wiki.hypr.land/Nix/
{pkgs, ...}: {
  home.packages = [pkgs.hyprland];

  wayland.windowManager.hyprland = {
    enable = true;
  };
}
