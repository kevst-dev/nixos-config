{
  config,
  pkgs,
  ...
}: {
  # Permitir paquetes no libres
  nixpkgs.config.allowUnfree = true;

  # Habilita la función Flakes y la nueva herramienta de línea de comandos nix
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Configuración de zona horaria
  time.timeZone = "America/Bogota";

  # Editor por defecto del sistema
  environment.variables = {
    EDITOR = "nvim";
  };

  # Paquetes del sistema
  environment.systemPackages = with pkgs; [
    git # Requerido para flakes
    just
  ];

  # Habilitar zsh a nivel de sistema (requerido para Home Manager)
  programs.zsh.enable = true;
}
