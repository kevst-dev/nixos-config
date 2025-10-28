#!/usr/bin/env bash

set -euo pipefail

##? Checkout a una rama de git usando selector fuzzy
#?? 1.0.0
##?
##? Uso:
##?   git-checkout.sh
##?
##? Descripción:
##?   Muestra ramas locales y remotas para hacer checkout con fzf

# Verificar que estemos en un repositorio git
if ! git rev-parse HEAD >/dev/null 2>&1; then
	echo "❌ No estás en un repositorio git"
	return 1
fi

main() {
	echo "🔍 Buscando ramas disponibles..."

	# Obtener lista de ramas con formato enriquecido:
	# - git branch --all --color: todas las ramas con colores
	# - format: HEAD indicator + nombre + fecha + último commit
	# - column --table: formatear en tabla alineada
	local branch
	branch=$(
		git branch --all --color \
			--format=$'%(HEAD) %(color:yellow)%(refname:short)\t%(color:green)%(committerdate:short)\t%(color:blue)%(subject)' |
			column --table --separator=$'\t' |
			fzf \
				--height 50% \
				--ansi \
				--prompt "Selecciona rama > " \
				--header "Ramas disponibles (nombre - fecha - último commit)" \
				--border
	)

	if [[ -n $branch ]]; then
		# Extraer nombre de rama del formato enriquecido:
		# awk: tomar la segunda columna (nombre de la rama)
		# sed: quitar prefijo "remotes/origin/" si existe
		local clean_branch
		clean_branch=$(echo "$branch" | awk '{print $2}' | sed 's#^remotes/origin/##')

		echo "🚀 Cambiando a rama: $clean_branch"
		git checkout "$clean_branch"
	else
		echo "🤷 No seleccionaste ninguna rama"
	fi
}

main "$@"
