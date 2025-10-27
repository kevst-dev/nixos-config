{
  description = "Configuraciones personales de NixOS";

  inputs = {
    # Fuente oficial del paquete de NixOS, usando la rama nixos-25.05
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    
    # nixCats para configuración de Neovim
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, nixCats, ... }@inputs: {
    # Configuración para WSL
    nixosConfigurations = {
      wsl = let
        username = "kevst";
        specialArgs = {inherit username;};
      in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;

          modules = [
            ./hosts/wsl/default.nix
            nixos-wsl.nixosModules.wsl  # Módulo para entornos WSL
            
            # Integración de Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/${username}/home.nix;
              home-manager.extraSpecialArgs = inputs // specialArgs // { inherit inputs; };
            }
          ];
        };
    };
  };
}
