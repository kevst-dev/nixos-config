#!/usr/bin/env bash

set -euo pipefail

##? Elimina ramas locales usando selector fuzzy
#?? 1.0.0
##?
##? Uso:
##?   git-branch-delete.sh
##?
##? Descripción:
##?   Muestra ramas locales (excepto la actual) para eliminar con fzf

# Verificar que estemos en un repositorio git
if ! git rev-parse HEAD >/dev/null 2>&1; then
	echo "❌ No estás en un repositorio git"
	return 1
fi

main() {
	echo "🔍 Buscando ramas locales para eliminar..."

	# Nota: Se excluye la rama actual usando grep -v "^\*" más abajo

	# Obtener lista de ramas locales con formato enriquecido:
	# - git branch --color: solo ramas locales con colores
	# - format: HEAD indicator + nombre + fecha + último commit
	# - grep -v "^\*": excluir rama actual (marcada con *)
	# - column --table: formatear en tabla alineada
	local branches
	branches=$(
		git branch --color \
			--format=$'%(HEAD) %(color:yellow)%(refname:short)\t%(color:green)%(committerdate:short)\t%(color:blue)%(subject)' |
			grep -v "^\*" |
			column --table --separator=$'\t' |
			fzf \
				--height 50% \
				--ansi \
				--multi \
				--prompt "Selecciona ramas a eliminar > " \
				--header "Ramas locales (nombre - fecha - último commit) | CTRL+A: todas, TAB: múltiples" \
				--border
	)

	if [[ -n $branches ]]; then
		echo "📋 Ramas seleccionadas para eliminar:"
		# Agregar prefijo "  - " a cada línea usando parameter expansion
		printf '  - %s\n' "$branches"

		echo -n "❓ ¿Confirmas eliminar estas ramas? [y/N]: "
		read -r confirm

		if [[ $confirm == "y" || $confirm == "Y" ]]; then
			echo "$branches" | while read -r branch_line; do
				if [[ -n $branch_line ]]; then
					# Extraer nombre de rama del formato enriquecido (primera columna después de espacios)
					local branch_name
					branch_name=$(echo "$branch_line" | awk '{print $1}' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]].*//')

					echo "🗑️  Eliminando rama: $branch_name"
					git branch -D "$branch_name" || {
						echo "⚠️  No se pudo eliminar '$branch_name' (usa -D para forzar)"
					}
				fi
			done
		else
			echo "❌ Operación cancelada"
		fi
	else
		echo "🤷 No seleccionaste ninguna rama"
	fi
}

main "$@"
