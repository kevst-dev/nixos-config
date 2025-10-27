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

      # definir categorías de dependencias
      categoryDefinitions.replace = ({ pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: {
        
        # dependencias en runtime
        lspsAndRuntimeDeps = {
          general = with pkgs; [ ];
        };

        # plugins que cargan al startup
        startupPlugins = {
          general = with pkgs.vimPlugins; [
            lze                  # plugin para lazy loading

            # dependencias compartidas (van aquí para estar disponibles)
            plenary-nvim         # librería lua
            nvim-web-devicons    # iconos
            nui-nvim             # UI components
          ];
        };

        # plugins opcionales (no cargan automáticamente)
        optionalPlugins = {
          neotree = with pkgs.vimPlugins; [
            neo-tree-nvim          # plugin principal para lazy loading
            # plenary-nvim         -- dependencia de neo-tree
            # nvim-web-devicons    -- dependencia de neo-tree
            # nui-nvim             -- dependencia de neo-tree
          ];
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
      });

      # definir paquetes específicos
      packageDefinitions.replace = {
        myHomeModuleNvim = {pkgs, name, ... }: {
          settings = {
            wrapRc = false;  # permitir symlink en lugar de bundle
            unwrappedCfgPath = "${config.home.homeDirectory}/nixos-config/dotfiles/nvim";
            aliases = [ "vim" "nvim" ];
          };
          # categorías a activar
          categories = {
            general = true;
            neotree = true;
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