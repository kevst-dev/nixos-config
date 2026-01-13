{
  lib,
  username,
  ...
}: {
  # Home Manager necesita información sobre ti y las
  # rutas que debe gestionar.
  home = {
    inherit username;
    homeDirectory = lib.mkDefault "/home/${username}";

    # stateVersion es la "Versión de Instalación Original" de Home Manager
    # - Marca de tiempo de cuándo instalaste Home Manager por primera vez
    # - NUNCA lo cambies (incluso si actualizas a versiones nuevas)
    # - Solo existe para compatibilidad con datos con estado
    # - Cambiarlo puede causar pérdida de datos
    stateVersion = "25.05";
  };

  # Permitir que Home Manager se instale y gestione a sí mismo.
  programs.home-manager.enable = true;
}
