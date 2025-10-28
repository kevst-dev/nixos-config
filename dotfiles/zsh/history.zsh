#!/bin/zsh

# =============================================================================
# Configuración del historial
# =============================================================================

# Define dónde almacenar el historial.
export HISTFILE="$HOME/.zsh_history"

# Cuántos comandos se guardarán en el archivo
export SAVEHIST=$((100 * 1000))

# Cuántos comandos cargará zsh en la memoria.
export HISTSIZE=$(awk "BEGIN { print int(1.2 * $SAVEHIST) }")

# Opciones del historial
setopt HIST_IGNORE_ALL_DUPS # No guardar duplicados
setopt HIST_FIND_NO_DUPS    # No mostrar duplicados en búsqueda
setopt HIST_IGNORE_SPACE    # Ignorar comandos que empiecen con espacio
setopt HIST_SAVE_NO_DUPS    # No guardar duplicados al escribir archivo
setopt SHARE_HISTORY        # Compartir historial entre sesiones
setopt APPEND_HISTORY       # Agregar al historial, no sobrescribir
setopt INC_APPEND_HISTORY   # Agregar comandos inmediatamente
setopt HIST_VERIFY          # Mostrar comando antes de ejecutar con !! y !n
