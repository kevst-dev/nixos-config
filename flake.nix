{
  description = "Configuraciones personales de NixOS - Multi-host";

  inputs = {
    # Fuente oficial del paquete de NixOS, usando la rama unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Framework para flakes modulares y organizados
    # Referencia: https://flake.parts/
    flake-parts.url = "github:hercules-ci/flake-parts";

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

    # Zen Browser
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    # Front‑end de entornos de desarrollo: mise-en-place
    mise = {
      url = "github:jdx/mise";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (
      {
        self,
        inputs,
        withSystem,
        ...
      }: let
        # Diccionarios con la configuración de cada host
        hosts = import ./hosts.nix;

        # Helper para crear hosts con configuración modular.
        # Los datos del host (ip/username/interface) se derivan de `hosts.${hostname}`
        # para que hosts.nix sea la única fuente de verdad.
        mkHost = {
          hostname,
          includeWSL ? false,
          userConfig,
          extraHomeUsers ? {},
        }: let
          inherit (inputs.nixpkgs) lib;
          cfg = hosts.${hostname};
          inherit (cfg) ip username;
          interface = cfg.interface or null;
          system = "x86_64-linux";

          # Args compartidos entre specialArgs y extraSpecialArgs (deduplicación)
          sharedArgs = {
            inherit inputs hostname ip username interface hosts;
          };

          # Módulos comunes a TODOS los hosts: overlays globales, SOPS y Home Manager
          commonModules = [
            # Overlays globales (patches a paquetes de nixpkgs). Ver overlays/opencode.nix.
            {
              nixpkgs.overlays = [(import ./overlays/opencode.nix)];
            }
            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users = let
                  baseUsers = {${username} = import userConfig;};
                  # Importa la ruta de cada extraHomeUsers como un módulo de Home Manager
                  extraUsers =
                    lib.mapAttrs' (name: path: {
                      inherit name;
                      value = import path;
                    })
                    extraHomeUsers;
                in
                  baseUsers // extraUsers;
                extraSpecialArgs = sharedArgs;
              };
            }
          ];

          # Módulo de WSL (solo cuando includeWSL = true, p. ej. host wsl)
          wslModule = lib.optionals includeWSL [inputs.nixos-wsl.nixosModules.wsl];
        in
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = sharedArgs;

            modules =
              [./hosts/${hostname}/default.nix]
              ++ commonModules
              ++ wslModule;
          };
      in {
        systems = ["x86_64-linux"];

        # Configuraciones por host
        flake.nixosConfigurations = {
          wsl =
            withSystem "x86_64-linux"
            (_:
              mkHost {
                hostname = "wsl";
                userConfig = ./. + "/users/${hosts.wsl.username}/wsl.nix";
                includeWSL = true;
              });

          turing =
            withSystem "x86_64-linux"
            (_:
              mkHost {
                hostname = "turing";
                userConfig = ./. + "/users/${hosts.turing.username}/turing.nix";
              });

          stallman =
            withSystem "x86_64-linux"
            (_:
              mkHost {
                hostname = "stallman";
                userConfig = ./. + "/users/${hosts.stallman.username}/stallman.nix";
              });

          tanenbaum =
            withSystem "x86_64-linux"
            (_:
              mkHost {
                hostname = "tanenbaum";
                userConfig = ./. + "/users/${hosts.tanenbaum.username}/tanenbaum.nix";
              });

          sagan =
            withSystem "x86_64-linux"
            (_:
              mkHost {
                hostname = "sagan";
                userConfig = ./. + "/users/${hosts.sagan.username}/sagan.nix";
              });
        };

        # Checks y demás salidas por sistema
        perSystem = {system, ...}: let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in {
          # Tests de integración
          checks = {
            # Test de integración de Turing
            test-turing = pkgs.testers.runNixOSTest (import ./tests/integration/test-turing.nix {
              inherit self pkgs;
              inherit (pkgs) lib;
            });
          };
        };
      }
    );
}
