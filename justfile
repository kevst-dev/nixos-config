# Reconstruye y activa el sistema sin reboot
rebuild_cmd := "nixos-rebuild switch --sudo"

# Muestra la lista de commandos disponibles
default:
    @just --list

############################################################################
#
# Comandos Nix relacionados con la máquina local
#
############################################################################

# Construir y cambiar a la configuración NixOS de la máquina actual
deploy:
	{{rebuild_cmd}} --flake .

# Actualizar inputs del flake y desplegar configuración
update:
	nix flake update
	nix flake update tests/unit
	nix flake update tests/integration
	{{rebuild_cmd}} --flake .

############################################################################
#
# Despliegues específicos por host
#
############################################################################

# Desplegar en host WSL
wsl:
	{{rebuild_cmd}} --flake .#wsl

# Desplegar en servidor Turing
turing:
	{{rebuild_cmd}} --flake .#turing

# Desplegar en laptop Stallman
stallman:
	{{rebuild_cmd}} --flake .#stallman

# Desplegar en el router Sagan
sagan:
	{{rebuild_cmd}} --flake .#sagan

############################################################################
#
# Comandos de desarrollo y linting
#
############################################################################

# Ejecutar todos los checks de calidad (linting, formateo, etc.)
check:
	nix develop ./dev -c pre-commit run --all-files

# Entrar al entorno de desarrollo (solo para debugging)
dev:
	nix develop ./dev

############################################################################
#
# Mantenimiento y limpieza
#
############################################################################

# Listar generaciones del sistema
generations:
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Ver espacio usado por /nix/store
store-size:
	@du -sh /nix/store

# Limpiar generaciones más viejas que N días (ej: just clean 7)
clean days="7":
	sudo nix-collect-garbage --delete-older-than {{days}}d
	@echo ""
	@echo "🧹 limpieza completada, espacio actual:"
	@du -sh /nix/store

# Limpiar todo excepto generación actual (máximo espacio liberado)
clean-all:
	sudo nix-collect-garbage -d
	@echo ""
	@echo "🧹 limpieza completa, espacio actual:"
	@du -sh /nix/store

############################################################################
#
# Módulos - Comandos organizados por contexto
#
############################################################################

mod test 'just/tests.just'
mod backup_turing 'just/backup_for_turing.just'
