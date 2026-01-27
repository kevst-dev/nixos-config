{
  pkgs,
  lib,
  ...
}: let
  servicePath = lib.makeBinPath [pkgs.podman pkgs.podman-compose pkgs.coreutils] + ":/run/current-system/sw/bin";
  runCompose = attrs: let
    dir = attrs.directory;
    extraAfter = attrs.after or [];
    extraWants = attrs.wants or [];
  in {
    service = {
      description = "Podman Compose - ${attrs.label}";
      after = ["default.target" "network-online.target"] ++ (map (svc: "${svc}.service") extraAfter);
      wantedBy = ["default.target"];
      enable = true;
      wants = map (svc: "${svc}.service") extraWants;
      # Límites de reinicio (van en [Unit], no en [Service])
      startLimitIntervalSec = 60;
      startLimitBurst = 3;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = dir;
        Environment = ["PATH=${servicePath}"];
        # Esperar 5 segundos antes de iniciar para evitar race conditions al boot
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
        TimeoutStartSec = "0";
        # Reintentar si falla al iniciar
        Restart = "on-failure";
        RestartSec = "10";
      };
    };
  };
  composeStacks = {
    traefik = runCompose {
      label = "Traefik";
      directory = "/mnt/nvme0n1/self-hosted/traefik";
    };
    cloudflare = runCompose {
      label = "Cloudflare Tunnel";
      directory = "/mnt/nvme0n1/self-hosted/cloudflare";
    };
    tinyauth = runCompose {
      label = "TinyAuth";
      directory = "/mnt/nvme0n1/self-hosted/tinyauth";
      after = ["podman-compose-traefik"];
      wants = ["podman-compose-traefik"];
    };
    homepage = runCompose {
      label = "Homepage";
      directory = "/mnt/nvme0n1/self-hosted/homepage";
      after = ["podman-compose-traefik"];
      wants = ["podman-compose-traefik"];
    };
  };
in {
  systemd.user.services = {
    podman-compose-traefik = composeStacks.traefik.service;
    podman-compose-cloudflare = composeStacks.cloudflare.service;
    podman-compose-tinyauth = composeStacks.tinyauth.service;
    podman-compose-homepage = composeStacks.homepage.service;
  };
}
