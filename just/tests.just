# ============================================================================
# Comandos de testing - NixOS Config
# ============================================================================
#
# Uso: just test <comando>
# ============================================================================

# Mostrar comandos disponibles
default:
	@just --list test

# ─────────────────────────────────────────────────────────────────────────────
# Tests unitarios (componentes individuales)
# ─────────────────────────────────────────────────────────────────────────────

# Ejecutar todos los tests unitarios
unit-all:
	cd ../tests/unit && nix run .#run-all-tests

# Ejecutar test unitario específico (ej: just test unit test-git)
unit name:
	cd ../tests/unit && rm -rf result*
	cd ../tests/unit && nix build .#checks.x86_64-linux.{{name}} -L -v

# Listar tests unitarios disponibles
unit-list:
	cd ../tests/unit && nix flake show

# ─────────────────────────────────────────────────────────────────────────────
# Tests de integración (sistemas completos)
# ─────────────────────────────────────────────────────────────────────────────

# Ejecutar todos los tests de integración
integration-all:
	nix flake check -L

# Ejecutar test de integración de Turing
integration-turing:
	nix build .#checks.x86_64-linux.test-turing -L -v

# Listar tests de integración disponibles
integration-list:
	nix flake show | grep -A 10 "checks"
