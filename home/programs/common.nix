{pkgs, ...}: {
  # Paquetes comunes para usuarios
  home.packages = with pkgs; [
    # desarrollo
    claude-code
    python314
    uv # gestor de paquetes Python ultrarrápido (requiere nix-ld para binarios)
    mise # Front‑end de entornos y herramientas de desarrollo (jdx/mise)

    # reemplazos modernos de herramientas CLI
    eza # reemplazo moderno de 'ls'
    bat # reemplazo moderno de 'cat'
    fzf # fuzzy finder para línea de comandos

    # Herramientas para desarrollar en rust
    cargo
    rustc
    rustfmt
    clippy

    # compilador C (necesario para rust/cargo)
    gcc
  ];
}
