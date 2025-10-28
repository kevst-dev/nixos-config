# Configuración de plugins relacionados con UI/interfaz
{pkgs}: {
  # plugins que cargan al startup
  startupPlugins = {
    general = with pkgs.vimPlugins; [
      lze # plugin para lazy loading

      # dependencias compartidas (van aquí para estar disponibles)
      plenary-nvim # librería lua
      nvim-web-devicons # iconos
      nui-nvim # UI components

      # colorschemes (cargan al inicio, configuración directa)
      kanagawa-paper-nvim # tema kanagawa
    ];
  };

  # plugins opcionales (no cargan automáticamente)
  optionalPlugins = {
    neotree = with pkgs.vimPlugins; [
      neo-tree-nvim # explorador de archivos
      plenary-nvim # dependencia de neo-tree
      nvim-web-devicons # dependencia de neo-tree
      nui-nvim # dependencia de neo-tree
    ];
    sessions = with pkgs.vimPlugins; [
      auto-session # guardado automático de sesiones por proyecto
    ];
    statusline = with pkgs.vimPlugins; [
      lualine-nvim # barra de estado moderna
      nvim-web-devicons # dependencia de neo-tree
    ];
  };
}
