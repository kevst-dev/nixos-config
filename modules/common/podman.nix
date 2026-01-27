{pkgs, ...}: {
  # Podman se configura aquí como módulo compartido porque es una configuración
  # de virtualización a nivel de sistema (no usuario). Permite compatibilidad con
  # Docker y composición de contenedores en hosts que lo necesiten (WSL y Turing).
  # Ubicado en modules/common/ para reutilización entre hosts del sistema.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Alias docker -> podman
    defaultNetwork.settings.dns_enabled = true;
  };
  # Paquetes necesarios para gestión de contenedores
  environment.systemPackages = with pkgs; [
    podman # CLI general necesario para compatibilidad docker y rootless
    podman-compose # soporte para podman-compose
    slirp4netns # networking rootless
    fuse-overlayfs # overlayfs rootless
    shadow # newuidmap/newgidmap para Podman rootless
    coreutils # sleep disponible globalmente
  ];
}
