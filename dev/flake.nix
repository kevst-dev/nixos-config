{
  description = "Development tools para nixos-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    git-hooks,
  }: let
    # Función para soportar múltiples sistemas sin flake-utils
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "x86_64-darwin"];
  in {
    # Pre-commit checks para cada sistema
    checks = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./..; # Apunta al directorio padre (nixos-config)
          hooks = {
            # === Hooks generales disponibles en git-hooks.nix ===
            check-added-large-files.enable = true; # Verifica archivos grandes
            check-case-conflicts.enable = true; # Verifica conflictos de nombres de archivo
            check-merge-conflicts.enable = true; # Verifica conflictos de fusión
            check-yaml.enable = true; # Verifica sintaxis YAML
            end-of-file-fixer.enable = true; # Añade newline al final de archivos

            # === Hooks para Nix ===
            # Alejandra formatter - Rápido y semánticamente correcto
            alejandra.enable = true;

            # Statix - Detecta antipatrones en código Nix
            statix = {
              enable = true;
              settings = {
                format = "stderr"; # stderr, errfmt, json
                ignore = []; # Patrones de archivos a ignorar
              };
            };

            # Deadnix - Detecta y elimina código muerto
            deadnix = {
              enable = true;
              settings = {
                edit = true; # Eliminar automáticamente código muerto
                noUnderscore = true; # Ignorar variables que empiecen con _
                quiet = false; # Mostrar output
              };
            };

            # === Hooks para Lua/Neovim ===
            # Lua Language Server (nativo en git-hooks.nix)
            lua-ls = {
              enable = true;
              settings = {
                checklevel = "Warning";
                configuration = {
                  # Configuración específica para Neovim
                  runtime = {
                    version = "LuaJIT";
                  };
                  workspace = {
                    library = ["${pkgs.neovim}/share/nvim/runtime/lua"];
                    checkThirdParty = false;
                  };
                  diagnostics = {
                    globals = ["vim" "nixCats"];
                  };
                };
              };
            };

            # StyLua formatter (hook personalizado)
            stylua = {
              enable = true;
              name = "Format Lua files with StyLua";
              entry = "${pkgs.stylua}/bin/stylua";
              files = "\\.lua$";
              language = "system";
            };

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
              excludes = [".*\\.zsh$"];
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
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (self.checks.${system}) pre-commit-check;
      in {
        default = pkgs.mkShell {
          # Heredar los buildInputs de pre-commit
          inherit (pre-commit-check) shellHook;
          buildInputs = with pkgs;
            [
              # Herramientas básicas
              just

              # Herramientas para Nix
              alejandra
              statix
              deadnix

              # Herramientas para Lua/Neovim
              stylua
              lua-language-server

              # Herramientas del pre-commit check
            ]
            ++ pre-commit-check.enabledPackages;
        };
      }
    );
  };
}
