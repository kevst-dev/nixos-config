{
  description = "Configuraciones personales de NixOS - Multi-host";

  inputs = {
    # Fuente oficial del paquete de NixOS, usando la rama nixos-25.11
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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

        modules =
          [
            ./hosts/${hostname}/default.nix
          ]
          ++ (
            if includeWSL
            then [nixos-wsl.nixosModules.wsl]
            else []
          )
          ++ [
            # Integración de Home Manager
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

      # TODO: Agregar turing después de validar que WSL funciona
    };
  };
}
