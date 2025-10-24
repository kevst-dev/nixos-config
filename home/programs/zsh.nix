{ config, pkgs, ... }: 
{
  # Habilitar zsh básico
  programs.zsh = {
    enable = true;
    initExtra = ""; # Deshabilitar .zshenv automático para evitar conflictos
  };
  

  # Enlazar .zshrc usando mkOutOfStoreSymlink
  home.file.".zshrc" = {
    source = config.lib.file.mkOutOfStoreSymlink 
      "${config.home.homeDirectory}/nixos-config/dotfiles/zsh/.zshrc";
  };
}