{
  description = "Development tools para nixos-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, git-hooks }:
    let
      # Función para soportar múltiples sistemas sin flake-utils
      forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "x86_64-darwin"];
    in
    {
      # Pre-commit checks para cada sistema
      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./..;  # Apunta al directorio padre (nixos-config)
            hooks = {
              # === Hooks generales disponibles en git-hooks.nix ===
              check-added-large-files.enable = true;  # Verifica archivos grandes
              check-case-conflicts.enable = true;     # Verifica conflictos de nombres de archivo
              check-merge-conflicts.enable = true;    # Verifica conflictos de fusión
              check-yaml.enable = true;               # Verifica sintaxis YAML
              end-of-file-fixer.enable = true;        # Añade newline al final de archivos
              
              # === Hooks específicos para shell ===
              # Formateo para archivos zsh
              shfmt = {
                enable = true;
                name = "Format zsh files";
                files = "\.zsh$";
              };
              
              # Linting para archivos bash/sh
              shellcheck = {
                enable = true;
                name = "Lint bash/sh files";
                files = "\\.(sh|bash)$";
                excludes = [ ".*\\.zsh$" ];
              };
              
              # Formateo para archivos bash/sh  
              shfmt-bash = {
                enable = true;
                name = "Format bash/sh files";
                files = "\.(sh|bash)$";
                entry = "${pkgs.shfmt}/bin/shfmt -w";
                language = "system";
              };
            };
          };
        }
      );

      # DevShells para cada sistema
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pre-commit-check = self.checks.${system}.pre-commit-check;
        in
        {
          default = pkgs.mkShell {
            # Heredar los buildInputs de pre-commit
            inherit (pre-commit-check) shellHook;
            buildInputs = with pkgs; [
              # Herramientas básicas
              just
              
              # Herramientas del pre-commit check
            ] ++ pre-commit-check.enabledPackages;
          };
        }
      );
    };
}
