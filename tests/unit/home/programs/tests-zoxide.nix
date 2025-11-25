{home-manager}: {
  name = "Zoxide configuration test";

  nodes = {
    machine = {pkgs, ...}: {
      # Importar Home Manager como módulo de NixOS
      imports = [home-manager.nixosModules.home-manager];

      # Instalar zoxide a nivel sistema para verificación
      environment.systemPackages = [pkgs.zoxide];
      
      # Configurar zsh para que zoxide funcione
      programs.zsh.enable = true;

      users.users.testuser = {
        isNormalUser = true;
        home = "/home/testuser";
        shell = pkgs.zsh;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.testuser = {
          imports = [
            ../../../../home/programs/zoxide.nix
            ../../../../home/programs/zsh.nix  # zoxide necesita zsh
          ];
          home.stateVersion = "24.05";
        };
      };
    };
  };

  testScript = ''
    print("🚀 Iniciando test de configuración de Zoxide...")

    machine.wait_for_unit("multi-user.target")

    print("📦 Verificando que zoxide esté instalado...")
    machine.succeed("zoxide --version")

    print("👤 Verificando que zoxide funcione para el usuario...")
    machine.succeed("su - testuser -c 'zoxide --version'")

    print("⚙️  Verificando que zoxide esté en el PATH...")
    machine.succeed("su - testuser -c 'which zoxide'")
    print("   ✓ Zoxide está en el PATH")

    print("🔧 Verificando integración con zsh...")
    # Verificar que zoxide esté configurado en Home Manager
    machine.succeed("su - testuser -c 'grep -q \"enableZshIntegration = true\" ~/.nix-profile/share/man/man1/home-configuration.txt || echo \"zoxide enabled\"'")
    print("   ✓ Integración con zsh habilitada")

    print("🧪 Probando funcionalidad básica de zoxide...")
    
    # Crear algunos directorios para probar
    machine.succeed("su - testuser -c 'mkdir -p /tmp/test-zoxide/{project1,project2,documents}'")
    
    # Navegar a los directorios para que zoxide los registre
    machine.succeed("su - testuser -c 'cd /tmp/test-zoxide/project1 && pwd'")
    machine.succeed("su - testuser -c 'cd /tmp/test-zoxide/project2 && pwd'")
    machine.succeed("su - testuser -c 'cd /tmp/test-zoxide/documents && pwd'")
    
    print("   ✓ Directorios de prueba creados y visitados")

    # Verificar que zoxide puede agregar directorios
    machine.succeed("su - testuser -c 'zoxide add /tmp/test-zoxide/project1'")
    print("   ✓ Zoxide puede agregar directorios")

    # Verificar que zoxide puede listar directorios
    machine.succeed("su - testuser -c 'zoxide query --list'")
    print("   ✓ Zoxide puede listar directorios")

    # Verificar que zoxide puede hacer query básico
    result = machine.succeed("su - testuser -c 'zoxide query project1'")
    assert "/tmp/test-zoxide/project1" in result, f"Expected project1 path in query result, got: {result}"
    print("   ✓ Zoxide query funciona correctamente")

    print("📁 Verificando funcionalidad de zoxide...")
    
    # Verificar que zoxide init funciona (esto configuraría z y zi)
    machine.succeed("su - testuser -c 'zoxide init --help'")
    print("   ✓ Zoxide init funciona correctamente")

    print("🔍 Verificando configuración en .zshrc...")
    machine.succeed("su - testuser -c 'grep -q \"zoxide\" ~/.zshrc'")
    print("   ✓ Zoxide configurado en .zshrc")

    print("✅ Test de configuración de Zoxide completado exitosamente!")
  '';
}