{pkgs, ...}: {
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

  # Configuramos git de forma declarativa para permitir el helper de credenciales
  # "store" apuntando a un archivo en $HOME. Así evitamos el error de
  # "read-only file system" cuando git intenta escribir en ~/.config/git/config
  # dentro de los perfiles inmutables de NixOS.
  programs.git = {
    enable = true;
    package = pkgs.git;
    config = {
      credential.helper = "store --file /home/kevst/.git-credentials";
    };
  };

  # Habilitar zsh a nivel de sistema (requerido para Home Manager)
  programs.zsh.enable = true;
}
