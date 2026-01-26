{
  pkgs,
  username,
  ...
}: {
  ##################################################################################################################
  # Auto-inicio rootless Podman Compose en Turing
  # Basado en "How does podman initialize after reboot?"
  ##################################################################################################################

  systemd.services = {
    # 1) Refresh Podman rootless state tras reboot para --restart=always
    "podman-refresh" = {
      description = "Refresh rootless Podman state";
      after = ["dbus.service"];
      wants = ["dbus.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.podman}/bin/podman ps --all";
        Type = "oneshot";
        User = username;
      };
    };

    # 2) Traefik Podman Compose
    "podman-compose-traefik" = {
      description = "Podman Compose - Traefik";
      after = ["podman-refresh.service"];
      wants = ["podman-refresh.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/mnt/nvme0n1/self-hosted/traefik";
        ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
        Restart = "always";
        RestartSec = "10s";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
        User = username;
      };
    };

    # 3) Cloudflare Tunnel Podman Compose
    "podman-compose-cloudflare" = {
      description = "Podman Compose - Cloudflare Tunnel";
      after = ["podman-refresh.service"];
      wants = ["podman-refresh.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/mnt/nvme0n1/self-hosted/cloudflare";
        ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
        Restart = "always";
        RestartSec = "10s";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
        User = username;
      };
    };

    # 4) Homepage Podman Compose
    "podman-compose-homepage" = {
      description = "Podman Compose - Homepage";
      after = ["podman-refresh.service" "podman-compose-traefik.service"];
      wants = ["podman-refresh.service" "podman-compose-traefik.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/mnt/nvme0n1/self-hosted/homepage";
        ExecStart = "${pkgs.podman-compose}/bin/podman-compose up -d";
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose down";
        Restart = "always";
        RestartSec = "10s";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
        User = username;
      };
    };
  };
}
