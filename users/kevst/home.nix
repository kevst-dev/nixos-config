{pkgs, ...}: {
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
  ];

  programs.git = {
    userName = "kevst";
    userEmail = "kevinca100711@gmail.com";
  };
}