# Configuración de plugins relacionados con análisis y resaltado de sintaxis
# -------------------------------------------------------------------------
# Este archivo define los plugins que proveen capacidades avanzadas de
# resaltado, indentación y manipulación sintáctica del código fuente.
{pkgs}: {
  # dependencias en runtime necesarias para treesitter
  lspsAndRuntimeDeps = {
    syntax = with pkgs; [
      gcc # compilador C requerido por treesitter para compilar parsers
      nodejs # requerido para :TSInstallFromGrammar
      tree-sitter # herramienta CLI de tree-sitter
    ];
  };

  # plugins que cargan al startup (disponibles inmediatamente)
  startupPlugins = {
    syntax = with pkgs.vimPlugins; [
      # Plugin principal de treesitter (cargar inmediatamente)
      nvim-treesitter
      nvim-treesitter-textobjects

      # Parsers por separado
      (nvim-treesitter.withPlugins (p:
        with p; [
          bash
          lua
          nix
          json
          yaml
          markdown
          vim
          just
        ]))
    ];
  };

  # plugins opcionales (no cargan automáticamente)
  optionalPlugins = {
    syntax = with pkgs.vimPlugins; [
      # Soporte adicional
      vim-just # soporte para archivos justfile
    ];
  };
}
