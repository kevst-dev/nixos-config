{ ... }:
{
  ##################################################################################################################
  #
  # Configuración de Home Manager para kevst en WSL
  # Setup completo de desarrollo
  #
  ##################################################################################################################

  imports = [
    # Config compartida (git, core, paquetes básicos)
    ./common.nix

    # Paquetes de desarrollo
    ../../home/programs/common.nix

    # Terminal y shell avanzado
    ../../home/programs/zsh.nix
    ../../home/programs/starship.nix
    ../../home/programs/zoxide.nix

    # Editor completo
    ../../home/programs/neovim
  ];
}
