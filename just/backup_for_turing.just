# ============================================================================
# Comandos de backup (restic) - Turing Server
# ============================================================================
#
# Este archivo contiene los comandos para gestionar backups en el servidor Turing.
# Usa restic con dos repositorios: local (NVMe) y remoto (Swiss Backup).
#
# Uso: just backup <comando>
# ============================================================================

# Mostrar comandos disponibles
default:
    @just --list backup_turing

# Variables de repositorios restic
# Nota: el password se obtiene de sops-nix en /run/secrets/restic_password
repository_turing := "-r /mnt/nvme0n1/backups/restic --password-file /run/secrets/restic_password"
repository_swiss := "-r swift:sb_project_SBI-KC131965:/nixos-turing-restic --password-file /run/secrets/restic_password"

# Prefijo para comandos Swiss (carga credenciales Swift)
swiss_run := "systemd-run --wait -P --property=EnvironmentFile=/etc/restic/swiss-backup.env"

# Mensajes
msg_turing := "💾 turing (local nvme):"
msg_swiss := "☁️  swiss backup (remoto):"

# ─────────────────────────────────────────────────────────────────────────────
# Listar snapshots
# ─────────────────────────────────────────────────────────────────────────────

# Listar snapshots en Turing (local)
snapshot-in-local:
	sudo restic {{repository_turing}} snapshots

# Listar snapshots en Swiss Backup (remoto)
snapshot-in-swiss:
	sudo {{swiss_run}} restic {{repository_swiss}} snapshots

# Listar todos los snapshots (ambos repos)
snapshot-all:
	@echo -e "\n{{msg_turing}}\n"
	@sudo restic {{repository_turing}} snapshots

	@echo -e "\n{{msg_swiss}}\n"
	@sudo {{swiss_run}} restic {{repository_swiss}} snapshots

# ─────────────────────────────────────────────────────────────────────────────
# Explorar contenido de snapshots
# ─────────────────────────────────────────────────────────────────────────────

# Listar archivos en un snapshot de Turing (ej: just backup-ls-turing latest)
ls-in-local snapshot:
	sudo restic {{repository_turing}} ls {{snapshot}}

# Listar archivos en un snapshot de Swiss (ej: just backup-ls-swiss f8be184c)
ls-in-swiss snapshot:
	sudo {{swiss_run}} restic {{repository_swiss}} ls {{snapshot}}

# ─────────────────────────────────────────────────────────────────────────────
# Restaurar datos
# ─────────────────────────────────────────────────────────────────────────────

# Restaurar path desde Turing (ej: just backup-restore-turing latest /DATA/AppData/homepage)
restore-in-local snapshot path:
	sudo restic {{repository_turing}} restore {{snapshot}} --target /tmp/restore --include "{{path}}"
	@echo ""
	@echo "Restaurado en: /tmp/restore{{path}}"

# Restaurar path desde Swiss (ej: just backup-restore-swiss latest /DATA/AppData/traefik)
restore-in-swiss snapshot path:
	sudo {{swiss_run}} restic {{repository_swiss}} restore {{snapshot}} --target /tmp/restore --include "{{path}}"
	@echo ""
	@echo "Restaurado en: /tmp/restore{{path}}"
		
# ─────────────────────────────────────────────────────────────────────────────
# Estadisticas
# ─────────────────────────────────────────────────────────────────────────────

# Ver estadisticas del repo Turing
stats-in-turing:
	sudo restic {{repository_turing}} stats

# Ver estadisticas del repo Swiss
stats-in-swiss:
	sudo {{swiss_run}} restic {{repository_swiss}} stats

# ─────────────────────────────────────────────────────────────────────────────
# Ejecutar backup manual
# ─────────────────────────────────────────────────────────────────────────────

# Ejecutar backup manual a Turing (local)
run-to-local:
	sudo systemctl start restic-backups-local.service
	@echo "📦 backup a turing iniciado, ver logs con: journalctl -u restic-backups-local -f"

# Ejecutar backup manual a Swiss (remoto)
run-to-swiss:
	sudo systemctl start restic-backups-swiss-backup.service
	@echo "📦 backup a swiss iniciado, ver logs con: journalctl -u restic-backups-swiss-backup -f"

# ─────────────────────────────────────────────────────────────────────────────
# Ver timers (programación de jobs)
# ─────────────────────────────────────────────────────────────────────────────

# Listar todos los timers de restic (BACKUP y PRUNE)
# Muestra cuándo se ejecutan los jobs de backup y limpieza
timers:
	@echo "📅 Jobs de BACKUP:"
	@echo "   • local:      4 veces/día (00:00, 06:00, 12:00, 18:00)"
	@echo "   • swiss:      1 vez/día (con delay aleatorio)"
	@echo ""
	@echo "🧹 Jobs de PRUNE (limpieza):"
	@echo "   • local-prune:    domingo 03:00"
	@echo "   • swiss-prune:   sábado 02:00"
	@echo ""
	systemctl list-timers | grep restic

# ─────────────────────────────────────────────────────────────────────────────
# Prune (limpieza de snapshots muy antiguos)
# ─────────────────────────────────────────────────────────────────────────────

# Ejecutar prune usando el servicio de systemd configurado con nix-os
run-prune-local:
	sudo systemctl start restic-backups-local-prune.service
	@echo "🧹 prune local iniciado, ver logs con: journalctl -u restic-backups-local-prune -f"

run-prune-swiss:
	sudo systemctl start restic-backups-swiss-backup-prune.service
	@echo "🧹 prune swiss iniciado, ver logs con: journalctl -u restic-backups-swiss-backup-prune -f"

# ─────────────────────────────────────────────────────────────────────────────
# Check (verificación de integridad)
# ─────────────────────────────────────────────────────────────────────────────

# Verificar integridad del repo local
check-local:
	sudo restic {{repository_turing}} check --read-data

# Verificar integridad del repo Swiss
check-swiss:
	sudo {{swiss_run}} restic {{repository_swiss}} check --read-data
