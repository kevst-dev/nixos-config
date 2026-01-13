{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        # pkgs con allowUnfree para tests que lo necesiten
        pkgsUnfree = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        checks = {
          # Tests ejecutados por nix flake check
          test-git = pkgs.testers.runNixOSTest (import ./home/programs/tests-git.nix {
            inherit (inputs) home-manager;
          });
          test-starship = pkgs.testers.runNixOSTest (import ./home/programs/tests-starship.nix {
            inherit (inputs) home-manager;
          });
          test-zsh = pkgs.testers.runNixOSTest (import ./home/programs/tests-zsh.nix {
            inherit (inputs) home-manager;
          });
          test-zoxide = pkgs.testers.runNixOSTest (import ./home/programs/tests-zoxide.nix {
            inherit (inputs) home-manager;
          });
          test-neovim = pkgs.testers.runNixOSTest (import ./home/programs/tests-neovim.nix {
            inherit (inputs) home-manager;
          });
          test-common = pkgsUnfree.testers.runNixOSTest (import ./home/programs/tests-common.nix {
            inherit (inputs) home-manager;
          });
        };

        packages = {
          # Script para ejecutar todos los tests con output
          run-all-tests = pkgs.writeShellScriptBin "run-all-tests" ''
            set -e
            echo "🚀 Ejecutando todos los tests..."

            echo "📋 Test: common"
            nix build .#checks.x86_64-linux.test-common -L -v --print-build-logs --rebuild

            echo "📋 Test: git"
            nix build .#checks.x86_64-linux.test-git -L -v --print-build-logs --rebuild

            echo "📋 Test: starship"
            nix build .#checks.x86_64-linux.test-starship -L -v --print-build-logs --rebuild

            echo "📋 Test: zsh"
            nix build .#checks.x86_64-linux.test-zsh -L -v --print-build-logs --rebuild

            echo "📋 Test: zoxide"
            nix build .#checks.x86_64-linux.test-zoxide -L -v --print-build-logs --rebuild

            echo "📋 Test: neovim"
            nix build .#checks.x86_64-linux.test-neovim -L -v --print-build-logs --rebuild

            echo "✅ Todos los tests completados exitosamente!"
          '';
        };
      };
    };
}
