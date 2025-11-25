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
	nixos-rebuild switch --flake . --use-remote-sudo

# Actualizar inputs del flake y desplegar configuración
update:
	nix flake update
	nixos-rebuild switch --flake . --use-remote-sudo

debug:
  nixos-rebuild switch --flake . --use-remote-sudo --show-trace --verbose

############################################################################
#
# Despliegues específicos por host
#
############################################################################

# Desplegar en host WSL
wsl:
	nixos-rebuild switch --flake .#wsl --use-remote-sudo

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
