{
  description = "Configuraciones personales de NixOS - Multi-host";

  inputs = {
    # Fuente oficial del paquete de NixOS, usando la rama unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland - NixOS module (requerido para session files y XDG portals)
    # Referencia: https://wiki.hypr.land/Nix/
    hyprland.url = "github:hyprwm/Hyprland";

    # NOTA: Este input se declara para todos los hosts pero solo se USA en WSL.
    # Nix no soporta inputs condicionales/opcionales aún (2026).
    # Cuando se implemente (github.com/NixOS/nix/issues/7205), se puede marcar como opcional.
    # El módulo solo se aplica condicionalmente en host WSL (ver includeWSL = true).
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    # nixCats para configuración de Neovim
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    # SOPS-Nix para gestión de secretos
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    sops-nix,
    ...
  } @ inputs: let
    # Diccionarios con la configuración de cada host
    hosts = import ./hosts.nix;

    # Helper para crear hosts con configuración modular
    mkHost = {
      hostname,
      ip, # IP del host (null para dynamic)
      username, # Usuario del host
      system ? "x86_64-linux",
      includeWSL ? false,
      userConfig,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit hostname ip username;
        };

        # CONSTRUCCIÓN DE MÓDULOS
        # El operador ++ concatena (une) listas en Nix
        # Ejemplo: [1, 2] ++ [3, 4] → [1, 2, 3, 4]
        #
        # Estamos construyendo una lista de módulos uniendo 3 bloques:
        # BLOQUE 1 (siempre) ++ BLOQUE 2 (condicional) ++ BLOQUE 3 (siempre)

        modules =
          # BLOQUE 1: Configuración base del host (SIEMPRE se incluye)
          # Contiene la config específica del sistema para este host
          [
            ./hosts/${hostname}/default.nix
          ]
          # BLOQUE 2: Módulo de WSL (CONDICIONAL - solo si includeWSL = true)
          # Para WSL: [nixos-wsl.nixosModules.wsl]
          # Para otros hosts: [] (lista vacía)
          ++ (
            if includeWSL
            then [nixos-wsl.nixosModules.wsl]
            else []
          )
          # BLOQUE 3: SOPS-Nix (Gestión de secretos)
          ++ [sops-nix.nixosModules.sops]
          # BLOQUE 4: Configuración de Home Manager (SIEMPRE se incluye)
          # Gestiona la configuración a nivel de usuario
          ++ [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import userConfig; # Importa config específica del host
                extraSpecialArgs = {
                  inherit inputs hostname ip username;
                };
              };
            }
          ];
      };
  in {
    # Configuraciones por host
    nixosConfigurations = {
      wsl = mkHost {
        hostname = "wsl";
        userConfig = ./. + "/users/${hosts.wsl.username}/wsl.nix";
        includeWSL = true;
        inherit (hosts.wsl) ip username;
      };

      turing = mkHost {
        hostname = "turing";
        userConfig = ./. + "/users/${hosts.turing.username}/turing.nix";
        includeWSL = false;
        inherit (hosts.turing) ip username;
      };

      stallman = mkHost {
        hostname = "stallman";
        userConfig = ./. + "/users/${hosts.stallman.username}/stallman.nix";
        includeWSL = false;
        inherit (hosts.stallman) ip username;
      };
    };

    # Tests de integración
    checks.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      # Test de integración de Turing
      test-turing = pkgs.testers.runNixOSTest (import ./tests/integration/test-turing.nix {
        inherit self pkgs;
        inherit (pkgs) lib;
      });
    };
  };
}
