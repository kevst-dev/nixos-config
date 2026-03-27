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
  username, # Variable que viene de flake.nix (ej: "kevst")
  ...
}: {
  # ───────────────────────────────────────────────────────────────────────────
  # SEGURIDAD: Permitir namespaces de usuario sin privilegios
  # Necesario para que podman rootless pueda crear contenedores aislados
  # ───────────────────────────────────────────────────────────────────────────
  security.unprivilegedUsernsClone = true;

  # ───────────────────────────────────────────────────────────────────────────
  # CONFIGURACIÓN DEL USUARIO
  # ───────────────────────────────────────────────────────────────────────────
  # statix-ignore: W20  # unifica bloques users para evitar claves duplicadas
  users = {
    users.${username} = {
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

    groups.${username} = {};

    # Usuario secundario "npc" (servidor) con la misma huella de shell/SSH
    users.npc = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "npc";
      group = "npc";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      linger = true;
      subUidRanges = [
        {
          startUid = 110000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 110000;
          count = 65536;
        }
      ];
    };
    groups.npc = {};
  };
}
