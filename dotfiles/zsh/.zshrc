#!/bin/zsh

main() {
    # Definir la ruta al directorio de dotfiles
    export DOTFILES_DIR="$HOME/nixos-config/dotfiles"
    export ZSH_DIR="$DOTFILES_DIR/zsh"

    # Cargar aliases
    source "$ZSH_DIR/aliases.sh"
}

main "$@"