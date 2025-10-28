#!/bin/zsh

main() {
	# Definir la ruta al directorio de dotfiles
	# NOTE: En NixOS estas variables se definen en home/programs/zsh.nix (envExtra)
	#       para asegurar que estén disponibles en todas las shells.
	#       En otros sistemas, descomenta las siguientes líneas:
	#
	#       export DOTFILES_DIR="$HOME/nixos-config/dotfiles"
	#       export ZSH_DIR="$DOTFILES_DIR/zsh"

	source "$ZSH_DIR/history.zsh"
	source "$ZSH_DIR/aliases.zsh"
	source "$ZSH_DIR/prompt.zsh"
	source "$ZSH_DIR/fzf/init.zsh"
}

main "$@"
