# Reconstruye y activa el sistema sin reboot
rebuild_cmd := "nixos-rebuild switch --use-remote-sudo"

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
# Módulos - Comandos organizados por contexto
#
############################################################################

mod test 'just/tests.just'
mod backup_turing 'just/backup_for_turing.just'
