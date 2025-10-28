#!/usr/bin/env bash

set -euo pipefail

##? Ver historial de commits de git con selector fuzzy
#?? 1.0.0
##?
##? Uso:
##?   git-log.sh
##?
##? Descripción:
##?   Muestra el historial de commits con colores y permite previsualizar cada commit

# Verificar que estemos en un repositorio git
if ! git rev-parse HEAD >/dev/null 2>&1; then
	echo "❌ No estás en un repositorio git"
	return 1
fi

main() {
	echo "🔍 Mostrando historial de commits..."

	# Git log con formato personalizado y colores:
	# %C(white)%h    - hash del commit en blanco
	# %C(green)%cs   - fecha del commit en verde
	# %C(blue)%s     - mensaje del commit en azul
	# %C(red)%d      - referencias (ramas/tags) en rojo
	local selected_commit
	selected_commit=$(
		git log --graph --color \
			--format='%C(white)%h - %C(green)%cs - %C(blue)%s%C(red)%d' |
			fzf \
				--ansi \
				--reverse \
				--no-sort \
				--height 80% \
				--prompt "Selecciona commit > " \
				--header "Historial de commits (Enter: ver detalles, Esc: salir)" \
				--border \
				--preview="
                # Extraer hash del commit (primeros 7 caracteres alfanuméricos)
                hash=\$(echo {} | grep -o \"[a-f0-9]\\{7\\}\" | head -1)
                if [[ -n \$hash ]]; then
                    git show --color \$hash
                fi
            " \
				--preview-window right:60%:wrap
	)

	if [[ -n $selected_commit ]]; then
		# Extraer hash del commit seleccionado
		local commit_hash
		commit_hash=$(echo "$selected_commit" | grep -o "[a-f0-9]\{7\}" | head -1)

		if [[ -n $commit_hash ]]; then
			echo "📋 Commit seleccionado: $commit_hash"
			echo "🔍 Mostrando detalles completos..."
			echo ""
			git show --stat --color "$commit_hash"
		else
			echo "❌ No se pudo extraer el hash del commit"
		fi
	else
		echo "🤷 No seleccionaste ningún commit"
	fi
}

main "$@"
