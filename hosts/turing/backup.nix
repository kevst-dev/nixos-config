# ═══════════════════════════════════════════════════════════════════════════════
# MÓDULO DE BACKUP - Turing Server
# ═══════════════════════════════════════════════════════════════════════════════
#
# Este módulo configura backups automáticos usando restic con estrategia 3-2-1:
#   - 3 copias de datos (original + local + remota)
#   - 2 medios diferentes (NVMe local + Swift remoto)
#   - 1 copia offsite (Swiss Backup en Suiza)
#
# ┌─────────────────────────────────────────────────────────────────────────────┐
# │                           ARQUITECTURA                                      │
# └─────────────────────────────────────────────────────────────────────────────┘
#
#                                     ┌─────────────────────┐
#                                ┌───▶│  Backup Local       │
#                                │    │  /mnt/nvme0n1/      │
# ┌─────────────────┐     ┌──────┴──┐ │  backups/restic     │
# │   /DATA/AppData │────▶│ Restic  │ └─────────────────────┘
# │   (~1GB datos)  │     │(cifrado)│
# └─────────────────┘     └──────┬──┘ ┌─────────────────────┐
#                                │    │ Swiss Backup (Swift)│
#                                └───▶│  nixos-turing-restic│
#                                     └─────────────────────┘
#
#                                     ┌─────────────────────┐
#                                ┌ ─ ▶│  NAS Self-hosted    │
#                                ╎    │  (FUTURO)           │
#                                └ ─ ─└─────────────────────┘
#
# ┌─────────────────────────────────────────────────────────────────────────────┐
# │                        DECISIONES DE DISEÑO                                 │
# └─────────────────────────────────────────────────────────────────────────────┘
#
# 1. PROVEEDOR REMOTO: Infomaniak Swiss Backup (Swift)
#    - Servidores en Suiza con protección de datos suiza
#    - Usa protocolo OpenStack Swift (recomendado por Infomaniak para restic)
#    - Auth URL: https://swiss-backup04.infomaniak.com/identity/v3
#    - Container: nixos-turing-restic
#
# 2. PATHS A RESPALDAR:
#    - /DATA/AppData: Configuraciones y datos de todos los servicios
#
# 3. EXCLUSIONES (para optimizar espacio y tiempo):
#    - Caches y archivos temporales (regenerables)
#    - Immich: Solo se respalda DB y config, NO los archivos media
#      (los uploads, thumbs, encoded-video y library son regenerables
#      o el usuario tiene los originales)
#
# 4. FRECUENCIA:
#    - Local: Cada 6 horas (00:00, 06:00, 12:00, 18:00)
#    - Remoto: Diario con delay aleatorio de hasta 1h
#    - Prune LOCAL: Semanal (domingo 03:00)
#    - Prune REMOTO: Semanal (sábado 02:00)
#
# 5. RETENCIÓN:
#    - 7 snapshots diarios
#    - 4 snapshots semanales
#    - 6 snapshots mensuales
#
# 6. SEPARACIÓN BACKUP/PRUNE:
#    - El backup y el prune se ejecutan en jobs SEPARADOS
#    - Esto permite controlar mejor la frecuencia de limpieza
#    - Prune es más costoso en recursos, ejecutarlo semanalmente es suficiente
#    - Los timers de prune están configurados para ejecutarse cuando NO hay backup activo
#
# ┌─────────────────────────────────────────────────────────────────────────────┐
# │                     CONFIGURACIÓN MANUAL REQUERIDA                          │
# └─────────────────────────────────────────────────────────────────────────────┘
#
# Antes de aplicar esta configuración, crear los archivos de secretos:
#
#   sudo mkdir -p /etc/restic
#   sudo chmod 700 /etc/restic
#
#   # 1. Contraseña de cifrado del repositorio restic (generar una fuerte)
#   echo "TU_CONTRASEÑA_SEGURA" | sudo tee /etc/restic/password
#   sudo chmod 600 /etc/restic/password
#
#   # 2. Credenciales Swift de Infomaniak (generar password en panel Swiss Backup)
#   sudo tee /etc/restic/swiss-backup.env << 'EOF'
#   OS_AUTH_URL=https://swiss-backup04.infomaniak.com/identity/v3
#   OS_REGION_NAME=RegionOne
#   OS_USER_DOMAIN_NAME=default
#   OS_PROJECT_DOMAIN_NAME=default
#   OS_TENANT_NAME=sb_project_SBI-KC131965
#   OS_USERNAME=SBI-KC131965
#   OS_PASSWORD=tu_password_de_infomaniak
#   EOF
#   sudo chmod 600 /etc/restic/swiss-backup.env
#
# ┌─────────────────────────────────────────────────────────────────────────────┐
# │  ⚠️  ADVERTENCIA: GUARDA ESTOS SECRETOS EN UN LUGAR SEGURO                  │
# └─────────────────────────────────────────────────────────────────────────────┘
#
# Sin /etc/restic/password NO PODRÁS RECUPERAR LOS BACKUPS.
# Los datos están cifrados y sin esta contraseña son irrecuperables.
#
# Recomendación para guardar los secretos:
#   - Password de restic    → Password manager (Bitwarden) + copia física
#   - Credenciales Swiss    → Password manager (se pueden regenerar en Infomaniak)
#
# En caso de desastre total, necesitarás:
#   1. La contraseña de restic (para descifrar)
#   2. Acceso a Swiss Backup (credenciales o regenerar desde panel Infomaniak)
#   3. Instalar restic en cualquier máquina Linux
#   4. Ejecutar: restic -r swift:sb_project_SBI-KC131965:/nixos-turing-restic restore latest --target /destino
#
# ┌─────────────────────────────────────────────────────────────────────────────┐
# │                          COMANDOS ÚTILES                                    │
# └─────────────────────────────────────────────────────────────────────────────┘
#
# ═══════════════════════════════════════════════════════════════════════════════
# BACKUP
# ═══════════════════════════════════════════════════════════════════════════════
#
# # Ejecutar backup manualmente:
# sudo systemctl start restic-backups-local.service
# sudo systemctl start restic-backups-swiss-backup.service
#
# # Ver logs:
# sudo journalctl -u restic-backups-local.service -f
# sudo journalctl -u restic-backups-swiss-backup.service -f
#
# # Ver timers programados:
# systemctl list-timers | grep restic

# ═══════════════════════════════════════════════════════════════════════════════
# VERIFICAR BACKUPS
# ═══════════════════════════════════════════════════════════════════════════════
#
# # Ver snapshots local:
# sudo restic -r /mnt/nvme0n1/backups/restic --password-file /etc/restic/password snapshots
#
# # Ver snapshots Swiss:
# source /etc/restic/swiss-backup.env
# restic -r swift:sb_project_SBI-KC131965:/nixos-turing-restic --password-file /etc/restic/password snapshots
#
# # Ver tamaño del repositorio:
# sudo restic -r /mnt/nvme0n1/backups/restic --password-file /etc/restic/password stats

# ═══════════════════════════════════════════════════════════════════════════════
# PRUNE (LIMPIEZA) - Se ejecuta automáticamente 1 vez por semana
# ═══════════════════════════════════════════════════════════════════════════════
#
# # PRUNE AUTOMÁTICO - Estos jobs se ejecutan automáticamente:
# # - local-prune:    domingo 03:00 (restic-backups-local-prune.service)
# # - swiss-prune:    sábado 02:00 (restic-backups-swiss-backup-prune.service)
#
# # Ver timers de prune:
# systemctl list-timers | grep prune
#
# # Ejecutar prune manualmente (para probar o emergencia):
# sudo systemctl start restic-backups-local-prune.service
# sudo systemctl start restic-backups-swiss-backup-prune.service
#
# # Ver logs de prune:
# sudo journalctl -u restic-backups-local-prune.service -f
# sudo journalctl -u restic-backups-swiss-backup-prune.service -f

# ═══════════════════════════════════════════════════════════════════════════════
# PRUNE MANUAL (sin usar systemd)
# ═══════════════════════════════════════════════════════════════════════════════
#
# # Ver qué se eliminaría SIN ejecutar (dry-run):
# sudo restic -r /mnt/nvme0n1/backups/restic --password-file /etc/restic/password \
#   forget --dry-run --keep-daily 7 --keep-weekly 4 --keep-monthly 6
#
# # Ejecutar prune manualmente:
# sudo restic -r /mnt/nvme0n1/backups/restic --password-file /etc/restic/password \
#   forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6
#
# # Para Swiss Backup:
# source /etc/restic/swiss-backup.env
# restic -r swift:sb_project_SBI-KC131965:/nixos-turing-restic \
#   --password-file /etc/restic/password forget --prune \
#   --keep-daily 7 --keep-weekly 4 --keep-monthly 6

# ═══════════════════════════════════════════════════════════════════════════════
# RESTAURACIÓN
# ═══════════════════════════════════════════════════════════════════════════════
#
# # Restaurar archivo específico (ejemplo):
# sudo restic -r /mnt/nvme0n1/backups/restic --password-file /etc/restic/password \
#   restore latest --target /tmp/restore-test --include "/DATA/AppData/homepage"
#
# ═══════════════════════════════════════════════════════════════════════════════
{pkgs, config, ...}: let
  # ─────────────────────────────────────────────────────────────────────────────
  # Configuración común para todos los backups
  # ─────────────────────────────────────────────────────────────────────────────
  commonPaths = [
    "/mnt/nvme0n1/immich"
    "/mnt/nvme0n1/jellyfin"
    "/DATA/AppData/inventree-marco"
    # "/DATA/AppData/inventree-sandro"
    # "/DATA/AppData/pocketid"
    "/DATA/AppData/traefik"
    "/DATA/AppData/tududi"
    "/DATA/AppData/papra/"
    "/DATA/AppData/gitea/"
    "/DATA/AppData/vaultwarden/"
  ];

  commonExcludes = [
    # Caches y temporales (regenerables)
    "**/cache"
    "**/Cache"
    "**/.cache"
    "**/logs"
    "**/*.log"
    "**/tmp"
    "**/temp"
    "**/.tmp"

    # Immich: Solo respaldar DB y config, excluir media
    # Los archivos media son muy grandes y el usuario tiene los originales
    "**/immich/upload"
    "**/immich/thumbs"
    "**/immich/encoded-video"
    "**/immich/library"

    # Jellyfin: Solo config, excluir media y cache
    "**/jellyfin/media"
    "**/jellyfin/cache"

    # InvenTree: /static regenera sola (pesa cientos de MB).
    "**/inventree-marco/static"
  ];

  commonPruneOpts = [
    "--group-by host" # Agrupar por host (ignorar paths diferentes)
    "--keep-daily 7" # Mantener 7 snapshots diarios
    "--keep-weekly 4" # Mantener 4 snapshots semanales
    "--keep-monthly 6" # Mantener 6 snapshots mensuales
  ];
in {
  # Instalar restic para comandos manuales de administración
  environment.systemPackages = [pkgs.restic];

  # ═══════════════════════════════════════════════════════════════════════════
  # BACKUP LOCAL - Primera línea de defensa
  # ═══════════════════════════════════════════════════════════════════════════
  # Backup rápido en disco local NVMe para recuperación inmediata.
  # Frecuencia alta (cada 6 horas) porque el costo es bajo.

  services.restic.backups.local = {
    initialize = true;
    repository = "/mnt/nvme0n1/backups/restic";

    paths = commonPaths;
    exclude = commonExcludes;

    passwordFile = config.sops.secrets.restic_password.path;

    # Cada 6 horas: 00:00, 06:00, 12:00, 18:00
    timerConfig = {
      OnCalendar = "*-*-* 00,06,12,18:00:00";
      Persistent = true;
    };

    # prune se ejecuta en job separado (local-prune)
    pruneOpts = [];
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # PRUNE LOCAL - Limpieza semanal del repositorio local
  # ═══════════════════════════════════════════════════════════════════════════════
  # Job separado para ejecutar prune 1 vez por semana
  # Esto permite controlar mejor la retención y no ejecutar prune en cada backup

  services.restic.backups.local-prune = {
    repository = "/mnt/nvme0n1/backups/restic";
    passwordFile = config.sops.secrets.restic_password.path;

    # Semanal: domingo a las 03:00
    timerConfig = {
      OnCalendar = "Sun 03:00:00";
      Persistent = true;
    };

    # Política de retención
    pruneOpts = commonPruneOpts;

    # paths = [] indica que NO hace backup, solo prune
    paths = [];
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # BACKUP REMOTO - Swiss Backup (Swift)
  # ═══════════════════════════════════════════════════════════════════════════
  # Backup offsite en Suiza para protección contra desastres locales.
  # Usa OpenStack Swift (recomendado por Infomaniak para restic).
  # Docs: https://docs.infomaniak.cloud/block_storage/swissbackup/

  services.restic.backups.swiss-backup = {
    initialize = true;
    repository = "swift:sb_project_SBI-KC131965:/nixos-turing-restic";

    paths = commonPaths;
    exclude = commonExcludes;

    passwordFile = config.sops.secrets.restic_password.path;
    environmentFile = "/etc/restic/swiss-backup.env";

    # Diario con delay aleatorio de hasta 1 hora
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };

    # prune se ejecuta en job separado (swiss-backup-prune)
    pruneOpts = [];
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # PRUNE SWISS - Limpieza semanal del repositorio remoto
  # ═══════════════════════════════════════════════════════════════════════════════
  # Job separado para ejecutar prune 1 vez por semana
  # Se ejecuta el sábado a las 02:00 (antes del backup del domingo)

  services.restic.backups.swiss-backup-prune = {
    repository = "swift:sb_project_SBI-KC131965:/nixos-turing-restic";
    passwordFile = config.sops.secrets.restic_password.path;
    environmentFile = "/etc/restic/swiss-backup.env";

    # Semanal: sábado a las 02:00 (con delay aleatorio de hasta 1h)
    timerConfig = {
      OnCalendar = "Sat 02:00:00";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };

    # Política de retención
    pruneOpts = commonPruneOpts;

    # paths = [] indica que NO hace backup, solo prune
    paths = [];
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # TODO FUTURO: BACKUP A NAS SELF-HOSTED
  # ═══════════════════════════════════════════════════════════════════════════
  # Cuando tengas un NAS en tu red local, descomentar y configurar:
  #
  # services.restic.backups.nas = {
  #   initialize = true;
  #   repository = "sftp:user@nas:/backups/turing";
  #   # Alternativa con rest-server: "rest:https://nas.local:8000/turing"
  #
  #   paths = commonPaths;
  #   exclude = commonExcludes;
  #
  #   passwordFile = config.sops.secrets.restic_password.path;
  #   # Para SFTP, configurar SSH keys en lugar de password
  #
  #   timerConfig = {
  #     OnCalendar = "daily";
  #     Persistent = true;
  #   };
  #
  #   pruneOpts = commonPruneOpts;
  # };
}
