#!/usr/bin/env bash

set -euo pipefail

##? Conecta a un contenedor en ejecución (Docker o Podman)
#?? 1.0.0
##?
##? Uso:
##?   container-connect.sh
##?
##? Descripción:
##?   Muestra un selector fuzzy con contenedores en ejecución y conecta al seleccionado.
##?   Funciona automáticamente con Docker y Podman.

# Detectar qué herramienta de contenedores está disponible y funcionando
detect_container_tool() {
    if command -v docker &> /dev/null && docker ps >/dev/null 2>&1; then
        echo "docker"
    elif command -v podman &> /dev/null && podman ps >/dev/null 2>&1; then
        echo "podman"
    else
        return 1
    fi
}

main() {
    local container_tool
    
    # Detectar herramienta disponible
    if ! container_tool=$(detect_container_tool); then
        echo "❌ No hay ninguna herramienta de contenedores disponible o funcionando"
        echo "   Verifica que Docker/Podman esté instalado y corriendo"
        return 1
    fi
    
    echo "🔍 Usando $container_tool para listar contenedores..."
    
    # Obtener lista de contenedores con formato: ID : NOMBRE
    local container
    container=$($container_tool ps | awk '{if (NR!=1) print $1 ": " $(NF)}' | fzf \
        --height 40% \
        --prompt "Selecciona contenedor > " \
        --header "Contenedores en ejecución ($container_tool)" \
        --border
    )
    
    if [[ -n $container ]]; then
        local container_id
        container_id=$(echo "$container" | awk -F ': ' '{print $1}')
        
        echo "🚀 Conectando al contenedor: $container_id"
        $container_tool exec -it "$container_id" /bin/bash || $container_tool exec -it "$container_id" /bin/sh
    else
        echo "🤷 No seleccionaste ningún contenedor"
    fi
}

main "$@"