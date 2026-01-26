{pkgs, ...}: {
  ##################################################################################################################
  #
  # Servicios systemd de usuario para auto-iniciar contenedores Podman en Turing
  # Estos servicios ejecutan podman-compose up/down automáticamente en boot
  #
  # TODO: Esto aun no funciona correctamente se debe hacer debug más adelante
  ##################################################################################################################

  systemd.user.services = {
    podman-compose-cloudflare = {
      Unit = {
        Description = "Podman Compose - Cloudflare Tunnel";
        After = ["network-online.target"];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/mnt/nvme0n1/self-hosted/cloudflare";
        ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };

    podman-compose-traefik = {
      Unit = {
        Description = "Podman Compose - Traefik";
        After = ["network-online.target"];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/mnt/nvme0n1/self-hosted/traefik";
        ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };

    podman-compose-homepage = {
      Unit = {
        Description = "Podman Compose - Homepage";
        After = ["network-online.target" "podman-compose-traefik.service"];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/mnt/nvme0n1/self-hosted/homepage";
        ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
