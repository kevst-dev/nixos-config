{
  description = "Configuraciones personales de NixOS - Multi-host";

  inputs = {
    # Fuente oficial del paquete de NixOS, usando la rama unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NOTA: Este input se declara para todos los hosts pero solo se USA en WSL.
    # Nix no soporta inputs condicionales/opcionales aún (2026).
    # Cuando se implemente (github.com/NixOS/nix/issues/7205), se puede marcar como opcional.
    # El módulo solo se aplica condicionalmente en host WSL (ver includeWSL = true).
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    # nixCats para configuración de Neovim
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    ...
  } @ inputs: let
    username = "kevst"; # Usuario único para todos los hosts

    # Helper para crear hosts con configuración modular
    mkHost = {
      hostname,
      userConfig, # Ruta al archivo de config del usuario (wsl.nix, turing.nix, etc)
      system ? "x86_64-linux",
      includeWSL ? false,
    }: let
      specialArgs = {inherit username;};
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = specialArgs // {inherit inputs;};

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
          # BLOQUE 3: Configuración de Home Manager (SIEMPRE se incluye)
          # Gestiona la configuración a nivel de usuario
          ++ [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import userConfig; # Importa config específica del host
                extraSpecialArgs = inputs // specialArgs // {inherit inputs;};
              };
            }
          ];
      };
  in {
    # Configuraciones por host
    nixosConfigurations = {
      wsl = mkHost {
        hostname = "wsl";
        userConfig = ./users/kevst/wsl.nix; # Config específica de WSL
        includeWSL = true;
      };

      turing = mkHost {
        hostname = "turing";
        userConfig = ./users/kevst/turing.nix; # Config específica de servidor
        includeWSL = false;
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
