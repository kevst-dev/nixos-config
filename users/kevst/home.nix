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
    ../../home/programs/zsh.nix
  ];

  programs.git = {
    userName = "kevst";
    userEmail = "kevinca100711@gmail.com";
  };
}