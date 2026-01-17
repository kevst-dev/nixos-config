{pkgs, ...}: {
  # Paquetes comunes para usuarios
  home.packages = with pkgs; [
    # desarrollo
    claude-code
    opencode

    # reemplazos modernos de herramientas CLI
    eza # reemplazo moderno de 'ls'
    bat # reemplazo moderno de 'cat'
    fzf # fuzzy finder para línea de comandos
  ];
}
