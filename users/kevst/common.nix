{pkgs, ...}: {
  ##################################################################################################################
  #
  # Configuración compartida de Home Manager para kevst
  # Usada por todos los hosts (WSL, servidor, etc.)
  #
  ##################################################################################################################

  imports = [
    ../../home/core.nix
    ../../home/programs/git.nix
  ];

  # Identidad de git (compartida entre todos los hosts)
  programs.git = {
    settings = {
      user.name = "kevst";
      user.email = "kevinca100711@gmail.com";
    };
  };

  # Paquetes comunes a todos los hosts
  home.packages = with pkgs; [
    htop
    curl
    wget
    tree
    ripgrep
    fd
  ];
}
