{ config, lib, inputs, ... }: let
  utils = inputs.nixCats.utils;
in {
  imports = [
    inputs.nixCats.homeModule
  ];
  config = {
    # namespace para las opciones de nixCats
    nixCats = {
      enable = true;
      
      # overlays estándar para plugins
      addOverlays = [
        (utils.standardPluginOverlay inputs)
      ];
      
      # nombre del paquete a instalar
      packageNames = [ "myHomeModuleNvim" ];

      # ruta al directorio de configuración de nvim
      luaPath = ../../dotfiles/nvim;

      # importar categorías de diferentes módulos
      categoryDefinitions.replace = ({ pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: 
        lib.recursiveUpdate
          (import ./ui.nix { inherit pkgs; })
          {
            # dependencias en runtime (para futuras herramientas)
            lspsAndRuntimeDeps = {
              general = with pkgs; [ ];
            };

            # librerías compartidas
            sharedLibraries = {
              general = with pkgs; [ ];
            };

            # variables de entorno
            environmentVariables = {
              # sin variables por ahora
            };

            # librerías de python
            python3.libraries = {
              # sin python por ahora
            };

            # argumentos extra del wrapper
            extraWrapperArgs = {
              # sin argumentos extra por ahora
            };
          }
      );

      # definir paquetes específicos
      packageDefinitions.replace = {
        myHomeModuleNvim = { pkgs, name, ... }: {
          settings = {
            wrapRc = false;  # permitir symlink en lugar de bundle
            unwrappedCfgPath = "${config.home.homeDirectory}/nixos-config/dotfiles/nvim";
            aliases = [ "vim" "nvim" ];
          };
          # categorías a activar
          categories = {
            general = true;
            neotree = true;
            sessions = true;
            colorscheme = true;
          };
          # información extra para lua
          extra = {
            # sin extras por ahora
          };
        };
      };
    };
  };
}