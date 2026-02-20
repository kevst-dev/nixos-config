{...}: {
  ##################################################################################################################
  #
  # Configuración de Home Manager para kevst en servidor Turing
  # Setup de servidor con herramientas esenciales
  #
  ##################################################################################################################

  imports = [
    # Config compartida (git, core, paquetes básicos)
    ./common.nix

    # Paquetes de desarrollo (podría ser diferente que WSL para un servidor)
    ../../home/programs/common.nix

    # Terminal y shell
    ../../home/programs/zsh.nix
    ../../home/programs/starship.nix
    ../../home/programs/zoxide.nix
    ../../home/programs/ssh.nix

    # Editor
    ../../home/programs/neovim
  ];
}
