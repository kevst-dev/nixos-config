{username, ...}: {
  # Home Manager necesita información sobre ti y las
  # rutas que debe gestionar.
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    # Este valor determina la versión de Home Manager con la que
    # tu configuración es compatible. Esto ayuda a evitar problemas
    # cuando una nueva versión de Home Manager introduce cambios
    # incompatibles con versiones anteriores.
    #
    # Puedes actualizar Home Manager sin cambiar este valor. Consulta
    # las notas de la versión de Home Manager para una lista de cambios
    # de versión de estado en cada lanzamiento.
    stateVersion = "25.05";
  };

  # Permitir que Home Manager se instale y gestione a sí mismo.
  programs.home-manager.enable = true;
}