#!/bin/zsh

main() {
    # Definir la ruta al directorio de dotfiles
    # NOTE: En NixOS estas variables se definen en home/programs/zsh.nix (envExtra)
    #       para asegurar que estén disponibles en todas las shells.
    #       En otros sistemas, descomenta las siguientes líneas:
    #
    #       export DOTFILES_DIR="$HOME/nixos-config/dotfiles"
    #       export ZSH_DIR="$DOTFILES_DIR/zsh"

    source "$ZSH_DIR/history.sh"
    source "$ZSH_DIR/aliases.sh"
    source "$ZSH_DIR/prompt.sh"
    source "$ZSH_DIR/fzf/init.sh"
}

main "$@"