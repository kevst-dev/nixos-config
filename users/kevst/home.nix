{pkgs, ...}: {
  ##################################################################################################################
  #
  # Toda la configuración de Home Manager de Kevst
  #
  ##################################################################################################################

  imports = [
    ../../home/core.nix
  
    ../../home/programs/common.nix
    ../../home/programs/git.nix
  ];

  programs.git = {
    userName = "kevst";
    userEmail = "kevinca100711@gmail.com";
  };
}