{home-manager}: {
  name = "Git configuration test";

  nodes = {
    machine = {pkgs, ...}: {
      # Importar Home Manager como módulo de NixOS
      imports = [home-manager.nixosModules.home-manager];

      # Instalar git a nivel sistema para el test
      environment.systemPackages = [pkgs.git];

      users.users.testuser = {
        isNormalUser = true;
        home = "/home/testuser";
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.testuser = {
          imports = [../../../../home/programs/git.nix];
          home.stateVersion = "24.05";
          programs.git = {
            settings = {
              user.name = "kevst";
              user.email = "kevinca100711@gmail.com";
            };
          };
        };
      };
    };
  };

  testScript = ''
    print("🚀 Iniciando test de configuración de Git...")

    machine.wait_for_unit("multi-user.target")

    print("📦 Verificando que git esté instalado...")
    machine.succeed("git --version")

    print("👤 Cambiando al usuario de prueba...")
    machine.succeed("su - testuser -c 'git --version'")

    print("⚙️  Verificando configuración básica de git...")
    machine.succeed("su - testuser -c 'git config user.name' | grep -q 'kevst'")
    print("   ✓ user.name = kevst")

    machine.succeed("su - testuser -c 'git config user.email' | grep -q 'kevinca100711@gmail.com'")
    print("   ✓ user.email = kevinca100711@gmail.com")

    print("🔧 Verificando configuración de line endings...")
    machine.succeed("su - testuser -c 'git config core.autocrlf' | grep -q 'input'")
    print("   ✓ core.autocrlf = input (convierte CRLF a LF al hacer commit)")

    machine.succeed("su - testuser -c 'git config core.eol' | grep -q 'lf'")
    print("   ✓ core.eol = lf (usa LF como line ending)")

    print("📦 Verificando que gh (GitHub CLI) esté disponible...")
    machine.succeed("su - testuser -c 'which gh'")
    print("   ✓ GitHub CLI instalado correctamente")

    print("🧪 Probando funcionalidad básica de git...")
    machine.succeed("su - testuser -c 'cd /tmp && git init test-repo'")
    machine.succeed("su - testuser -c 'cd /tmp/test-repo && echo \"test\" > README.md'")
    machine.succeed("su - testuser -c 'cd /tmp/test-repo && git add README.md'")
    machine.succeed("su - testuser -c 'cd /tmp/test-repo && git commit -m \"Initial commit\"'")
    print("   ✓ Git init, add y commit funcionan correctamente")

    print("✅ Test de configuración de Git completado exitosamente!")
  '';
}
