#!/usr/bin/env zsh

# ==========================================================================
# FZF Scripts - Alias y Documentación
# ==========================================================================
#
# Este archivo define alias para todos los scripts fzf disponibles.
# Cada alias incluye documentación sobre su propósito y uso.
#
# RECURSOS ÚTILES:
# - Guía completa de FZF + Git: https://thevaluable.dev/fzf-git-integration/
#   (Ideas para futuros scripts: file search, git status interactivo, stash management)
#
# ==========================================================================

# Verificar que fzf esté disponible
if ! command -v fzf &>/dev/null; then
	echo "⚠️  fzf no está instalado. Los scripts fzf no estarán disponibles."
	return 0
fi

# ==========================================================================
# INTEGRACIÓN FZF CON ZSH
# ==========================================================================

# Integración moderna de fzf (requiere fzf 0.48+)
# Proporciona key bindings: Ctrl+R (historial), Ctrl+T (archivos), Alt+C (directorios)
source <(fzf --zsh)

# ==========================================================================
# CONTENEDORES
# ==========================================================================

# Conectar a un contenedor en ejecución
# Uso: cc
# Descripción: Muestra lista fuzzy de contenedores y conecta al seleccionado
alias cc='$ZSH_DIR/fzf/container-connect.bash'

# ==========================================================================
# GIT
# ==========================================================================

# Checkout de rama con selector fuzzy
# Uso: gco
# Descripción: Muestra ramas disponibles y cambia a la seleccionada
alias gco='$ZSH_DIR/fzf/git-checkout.bash'

# Eliminar ramas con selector fuzzy
# Uso: gbd
# Descripción: Muestra ramas locales y elimina las seleccionadas
alias gbd='$ZSH_DIR/fzf/git-branch-delete.bash'

# Ver historial de commits con selector fuzzy
# Uso: glog
# Descripción: Navega por el historial de commits con preview
alias glog='$ZSH_DIR/fzf/git-log.bash'

# ==========================================================================
# INFORMACIÓN
# ==========================================================================

# Mostrar todos los alias fzf disponibles
alias fzf-help='echo "
🔍 Scripts FZF Disponibles:

📦 CONTENEDORES:
  cc          Conectar a contenedor en ejecución

🌿 GIT:
  gco         Checkout de rama
  gbd         Eliminar ramas
  glog        Historial de commits interactivo

⌨️  KEY BINDINGS:
  Ctrl+R      Búsqueda fuzzy en historial
  Ctrl+T      Buscar archivos
  Alt+C       Cambiar directorios

💡 Para más detalles, revisa los scripts en: \$ZSH_DIR/fzf/
"'
