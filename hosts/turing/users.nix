# =============================================================================
# CONFIGURACIÓN DEL USUARIO PARA TURING (SERVIDOR)
# =============================================================================
#
# Este archivo configura:
#   1. El usuario principal del servidor
#   2. Permisos para ejecutar contenedores sin root (rootless podman)
#   3. Servicios systemd de usuario (podman-compose)
#
# =============================================================================
{
  pkgs,
  lib,
  username, # Variable que viene de flake.nix (ej: "kevst")
  ...
}: let
  # Importa los servicios de podman-compose definidos en podman-user-services.nix
  podmanUserServices = import ./podman-user-services.nix {inherit pkgs lib;};
in {
  # ───────────────────────────────────────────────────────────────────────────
  # SEGURIDAD: Permitir namespaces de usuario sin privilegios
  # Necesario para que podman rootless pueda crear contenedores aislados
  # ───────────────────────────────────────────────────────────────────────────
  security.unprivilegedUsernsClone = true;

  # ───────────────────────────────────────────────────────────────────────────
  # CONFIGURACIÓN DEL USUARIO
  # ───────────────────────────────────────────────────────────────────────────
  users.users.${username} = {
    isNormalUser = true; # Usuario normal (no root, no sistema)
    shell = pkgs.zsh; # Shell por defecto
    group = username; # Grupo primario (mismo nombre que usuario)
    extraGroups = [
      "wheel" # Permite usar sudo
      "networkmanager" # Permite gestionar redes
    ];

    # ─── LINGER ───
    # MUY IMPORTANTE: Permite que los servicios del usuario se ejecuten
    # incluso cuando el usuario no tiene sesión activa (después de logout
    # o reboot). Sin esto, los contenedores se detendrían al cerrar sesión.
    linger = true;

    # ─── RANGOS DE UID/GID SUBORDINADOS ───
    # Necesarios para podman rootless. Permiten que los contenedores
    # tengan sus propios usuarios "virtuales" mapeados a rangos de UID/GID
    # que el kernel asigna de forma segura.
    #
    # Ejemplo: UID 0 dentro del contenedor → UID 100000 en el host
    # Esto da aislamiento de seguridad sin necesitar root real.
    subUidRanges = [
      {
        startUid = 100000; # Primer UID subordinado
        count = 65536; # Cantidad de UIDs disponibles
      }
    ];
    subGidRanges = [
      {
        startGid = 100000; # Primer GID subordinado
        count = 65536; # Cantidad de GIDs disponibles
      }
    ];
    # Los paquetes de podman están en modules/common/podman.nix
  };

  # Crear el grupo con el mismo nombre que el usuario
  users.groups.${username} = {};

  # ───────────────────────────────────────────────────────────────────────────
  # SERVICIOS SYSTEMD DE USUARIO
  # Importados desde podman-user-services.nix
  # ───────────────────────────────────────────────────────────────────────────
  systemd.user.services = podmanUserServices.systemd.user.services;
}
