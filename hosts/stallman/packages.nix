{
  inputs,
  pkgs,
  ...
}: {
  # Paquetes del sistema para stallman
  environment.systemPackages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.bitwarden-desktop
    pkgs.alsa-utils
  ];
}
