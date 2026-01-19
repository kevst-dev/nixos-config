{...}: {
  ##################################################################################################################
  #
  # Toda la configuración de Home Manager de Kevst
  #
  ##################################################################################################################

  imports = [
    ../../home/core.nix

    ../../home/programs/common.nix

    # Configuración básica del stack
    ../../home/programs/git.nix

    # Terminal y shell
    ../../home/programs/zsh.nix
    ../../home/programs/starship.nix
    ../../home/programs/zoxide.nix

    # Editor
    ../../home/programs/neovim

    # Nueva configuración de OpenCode (apunta a dotfiles)
    ../../home/programs/opencode.nix
  ];

  programs.git = {
    settings = {
      user.name = "kevst";
      user.email = "kevinca100711@gmail.com";
    };
  };
}
