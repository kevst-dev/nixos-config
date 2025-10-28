_: {
  # Instalar y habilitar Starship
  programs.starship = {
    enable = true;

    # Configuración básica
    settings = {
      # Agregar línea nueva antes del prompt
      add_newline = true;
    };
  };
}
