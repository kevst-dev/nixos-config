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
	nix flake update --flake tests/unit
	{{rebuild_cmd}} --flake .

debug:
	{{rebuild_cmd}} --flake . --show-trace --verbose

############################################################################
#
# Despliegues específicos por host
#
############################################################################

# Desplegar en host WSL
wsl:
	{{rebuild_cmd}} --flake .#wsl

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
# Comandos de testing
#
############################################################################

# Ejecutar todos los tests unitarios
test-unit-all:
	cd tests/unit && nix run .#run-all-tests

# Ejecutar un test específico (ej: just test-unit test-git)
test-unit test:
	cd tests/unit && rm -rf result*
	cd tests/unit && nix build .#checks.x86_64-linux.{{test}} -L -v --rebuild

# Listar tests disponibles
test-list:
	cd tests/unit && nix flake show
