_: {
  ##################################################################################################################
  #
  # Configuración básica de Vim
  # Para uso en servidores (alternativa ligera a Neovim)
  #
  ##################################################################################################################

  programs.vim = {
    enable = true;
    settings = {
      number = true;
      relativenumber = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
    };
    extraConfig = ''
      syntax on
      set mouse=a
      set clipboard=unnamedplus
    '';
  };
}
