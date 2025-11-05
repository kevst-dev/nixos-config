{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    home-manager,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {pkgs, ...}: {
        packages = {
          # Importar todos los tests que tengas
          test-example = pkgs.testers.runNixOSTest ./tests-example.nix;
          test-git = pkgs.testers.runNixOSTest (import ./tests-git.nix {
            inherit (inputs) home-manager;
          });
        };
      };
    };
}
