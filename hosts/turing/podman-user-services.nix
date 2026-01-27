# =============================================================================
# SERVICIOS PODMAN-COMPOSE COMO USUARIO (NO ROOT)
# =============================================================================
#
# Este archivo define servicios systemd de usuario para ejecutar contenedores
# con podman-compose. Los contenedores corren sin privilegios de root.
#
# ┌─────────────────────────────────────────────────────────────────────────────┐
# │ COMANDO MANUAL PARA SUBIR UN SERVICIO                                       │
# │                                                                             │
# │ Si un servicio no arranca automáticamente después de encender el servidor,  │
# │ usa este comando:                                                           │
# │                                                                             │
# │   systemctl --user restart podman-compose-<nombre>                          │
# │                                                                             │
# │ Ejemplos:                                                                   │
# │   systemctl --user restart podman-compose-traefik                           │
# │   systemctl --user restart podman-compose-cloudflare                        │
# │   systemctl --user restart podman-compose-tinyauth                          │
# │   systemctl --user restart podman-compose-homepage                          │
# │                                                                             │
# │ Para ver el estado:                                                         │
# │   systemctl --user status podman-compose-<nombre>                           │
# │                                                                             │
# │ Para ver logs:                                                              │
# │   journalctl --user -u podman-compose-<nombre> -f                           │
# │                                                                             │
# │ Para ver todos los contenedores:                                            │
# │   podman ps -a                                                              │
# └─────────────────────────────────────────────────────────────────────────────┘
#
# TODO: Verificar que los servicios arranquen correctamente después de un reboot
#
# =============================================================================
{
  pkgs,
  lib,
  ...
}: let
  # ───────────────────────────────────────────────────────────────────────────
  # PATH de binarios necesarios para que systemd encuentre podman y podman-compose
  # ───────────────────────────────────────────────────────────────────────────
  servicePath = lib.makeBinPath [pkgs.podman pkgs.podman-compose pkgs.coreutils] + ":/run/current-system/sw/bin";

  # ───────────────────────────────────────────────────────────────────────────
  # FUNCIÓN: runCompose
  # Genera la configuración de un servicio systemd para un stack de compose
  #
  # Parámetros (attrs):
  #   - label: Nombre descriptivo del servicio (ej: "Traefik")
  #   - directory: Ruta donde está el compose.yaml (ej: "/mnt/nvme0n1/self-hosted/traefik")
  #   - after: (opcional) Lista de servicios que deben iniciar ANTES que este
  #   - wants: (opcional) Lista de servicios que este QUIERE que estén activos
  # ───────────────────────────────────────────────────────────────────────────
  runCompose = attrs: let
    dir = attrs.directory;
    extraAfter = attrs.after or []; # Servicios que deben iniciar antes (orden)
    extraWants = attrs.wants or []; # Servicios deseados (dependencia suave)
  in {
    service = {
      description = "Podman Compose - ${attrs.label}";

      # ─── ORDEN DE INICIO ───
      # after: Este servicio espera a que estos targets/servicios estén listos
      # - default.target: El sistema está en estado normal de usuario
      # - network-online.target: La red está disponible
      # - extraAfter: Servicios adicionales (ej: traefik antes que homepage)
      after = ["default.target" "network-online.target"] ++ (map (svc: "${svc}.service") extraAfter);

      # wantedBy: Cuando default.target se activa, este servicio se inicia
      wantedBy = ["default.target"];
      enable = true;

      # wants: Servicios que queremos activos (dependencia suave, no falla si no existen)
      wants = map (svc: "${svc}.service") extraWants;

      # ─── PROTECCIÓN CONTRA LOOPS DE REINICIO ───
      # Si el servicio falla 3 veces en 60 segundos, systemd deja de intentar
      # IMPORTANTE: Estas opciones van en [Unit], no en [Service]
      startLimitIntervalSec = 60;
      startLimitBurst = 3;

      serviceConfig = {
        # ─── TIPO DE SERVICIO ───
        # Type=oneshot: El servicio ejecuta un comando y termina
        # RemainAfterExit=true: Aunque el proceso termine, systemd considera
        #                       el servicio "activo" (para poder hacer stop)
        Type = "oneshot";
        RemainAfterExit = true;

        # Directorio donde está el compose.yaml
        WorkingDirectory = dir;

        # PATH con los binarios necesarios
        Environment = ["PATH=${servicePath}"];

        # ─── COMANDOS ───
        # ExecStartPre: Espera 5 seg para evitar race conditions al boot
        #               (la red o podman pueden no estar listos inmediatamente)
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        # ExecStart: Levanta los contenedores en modo detached (-d)
        ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
        # ExecStop: Baja los contenedores limpiamente
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";

        # Sin timeout para el inicio (algunos contenedores tardan en descargar)
        TimeoutStartSec = "0";

        # ─── POLÍTICA DE REINICIO ───
        # on-failure: Si el comando falla (exit code != 0), reintentar
        # RestartSec: Esperar 10 segundos entre reintentos
        Restart = "on-failure";
        RestartSec = "10";
      };
    };
  };
  # ───────────────────────────────────────────────────────────────────────────
  # DEFINICIÓN DE STACKS (SERVICIOS)
  # Cada entrada genera un servicio systemd llamado: podman-compose-<nombre>
  #
  # Orden de inicio:
  #   1. traefik (reverse proxy - debe iniciar primero)
  #   2. cloudflare (túnel a internet - independiente de traefik)
  #   3. tinyauth (autenticación - depende de traefik)
  #   4. homepage (dashboard - depende de traefik)
  # ───────────────────────────────────────────────────────────────────────────
  composeStacks = {
    # Traefik: Reverse proxy que enruta el tráfico a los demás contenedores
    # Debe iniciar PRIMERO porque los otros servicios dependen de él
    traefik = runCompose {
      label = "Traefik";
      directory = "/mnt/nvme0n1/self-hosted/traefik";
    };

    # Cloudflare Tunnel: Expone los servicios a internet sin abrir puertos
    # Es independiente de traefik (se conecta directamente a Cloudflare)
    cloudflare = runCompose {
      label = "Cloudflare Tunnel";
      directory = "/mnt/nvme0n1/self-hosted/cloudflare";
    };

    # TinyAuth: Servicio de autenticación para proteger otros servicios
    # Depende de traefik porque traefik enruta las peticiones de auth
    tinyauth = runCompose {
      label = "TinyAuth";
      directory = "/mnt/nvme0n1/self-hosted/tinyauth";
      after = ["podman-compose-traefik"]; # Espera a que traefik esté listo
      wants = ["podman-compose-traefik"]; # Quiere que traefik esté activo
    };

    # Homepage: Dashboard para ver todos los servicios
    # Depende de traefik porque traefik enruta las peticiones al dashboard
    homepage = runCompose {
      label = "Homepage";
      directory = "/mnt/nvme0n1/self-hosted/homepage";
      after = ["podman-compose-traefik"];
      wants = ["podman-compose-traefik"];
    };
  };
  # =============================================================================
  # EXPORTACIÓN DE SERVICIOS
  # Estos se agregan a systemd.user.services en users.nix
  # =============================================================================
in {
  systemd.user.services = {
    podman-compose-traefik = composeStacks.traefik.service;
    podman-compose-cloudflare = composeStacks.cloudflare.service;
    podman-compose-tinyauth = composeStacks.tinyauth.service;
    podman-compose-homepage = composeStacks.homepage.service;
  };
}
