{...}: {
  ##################################################################################################################
  #
  # Configuración de Home Manager para kevst en el router Sagan
  # Setup mínimo de router: herramientas esenciales y terminal, sin editor pesado
  # para ahorrar RAM (4GB).
  #
  ##################################################################################################################

  imports = [
    # Config compartida (git, core, paquetes básicos)
    ./common.nix

    # Terminal y shell
    ../../home/programs/zsh.nix
    ../../home/programs/starship.nix
    ../../home/programs/zoxide.nix

    # SSH client (github, gitea-turing)
    ../../home/programs/ssh.nix

    # Editor
    ../../home/programs/neovim
  ];
}
