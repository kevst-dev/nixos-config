{home-manager}: {
  name = "Starship configuration test";

  nodes = {
    machine = {pkgs, ...}: {
      # Importar Home Manager como módulo de NixOS
      imports = [home-manager.nixosModules.home-manager];

      # Instalar starship a nivel sistema para verificación
      environment.systemPackages = [pkgs.starship];

      users.users.testuser = {
        isNormalUser = true;
        home = "/home/testuser";
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.testuser = {
          imports = [../../../../home/programs/starship.nix];
          home.stateVersion = "24.05";
        };
      };
    };
  };

  testScript = ''
    print("🚀 Iniciando test de configuración de Starship...")

    machine.wait_for_unit("multi-user.target")

    print("📦 Verificando que starship esté instalado...")
    machine.succeed("starship --version")

    print("👤 Verificando que starship funcione para el usuario...")
    machine.succeed("su - testuser -c 'starship --version'")

    print("⚙️  Verificando configuración de Starship...")
    machine.succeed("su - testuser -c 'test -f ~/.config/starship.toml'")
    print("   ✓ Archivo de configuración starship.toml existe")

    print("🔧 Verificando configuración add_newline...")
    machine.succeed("su - testuser -c 'grep -q \"add_newline = true\" ~/.config/starship.toml'")
    print("   ✓ add_newline = true configurado correctamente")

    print("🎨 Probando generación de prompt...")
    machine.succeed("su - testuser -c 'cd /tmp && starship prompt'")
    print("   ✓ Starship genera prompt correctamente")

    print("🧪 Verificando que el prompt funcione en diferentes directorios...")
    machine.succeed("su - testuser -c 'mkdir -p /tmp/test-dir && cd /tmp/test-dir && starship prompt'")
    print("   ✓ Prompt funciona en diferentes directorios")

    print("✅ Test de configuración de Starship completado exitosamente!")
  '';
}
