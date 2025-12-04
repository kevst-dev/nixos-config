{home-manager}: {
  name = "Common packages configuration test";

  nodes = {
    machine = {...}: {
      # Importar Home Manager como módulo de NixOS
      imports = [home-manager.nixosModules.home-manager];

      users.users.testuser = {
        isNormalUser = true;
        home = "/home/testuser";
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.testuser = {
          imports = [../../../../home/programs/common.nix];
          home.stateVersion = "24.05";
        };
      };
    };
  };

  testScript = ''
    print("🚀 Iniciando test de configuración de paquetes comunes...")

    machine.wait_for_unit("multi-user.target")

    # Verificar que Home Manager se completó exitosamente
    print("🏠 Verificando que Home Manager se ejecutó correctamente...")
    machine.wait_until_succeeds("systemctl show home-manager-testuser.service --property=ExecMainStatus | grep -q 'ExecMainStatus=0'", timeout=60)
    print("   ✓ Home Manager se completó exitosamente")

    # Verificar directamente que los paquetes estén disponibles
    print("📦 Verificando que Claude Code esté disponible...")
    machine.wait_until_succeeds("su - testuser -c 'which claude'", timeout=60)
    print("   ✓ Claude Code instalado correctamente")

    print("📦 Verificando que eza (reemplazo de ls) esté disponible...")
    machine.succeed("su - testuser -c 'which eza'")
    machine.succeed("su - testuser -c 'eza --version'")
    print("   ✓ eza instalado y funcionando")

    print("📦 Verificando que bat (reemplazo de cat) esté disponible...")
    machine.succeed("su - testuser -c 'which bat'")
    machine.succeed("su - testuser -c 'echo \"test content\" | bat --style=plain'")
    print("   ✓ bat instalado y funcionando")

    print("📦 Verificando que fzf (fuzzy finder) esté disponible...")
    machine.succeed("su - testuser -c 'which fzf'")
    machine.succeed("su - testuser -c 'echo -e \"option1\\noption2\\noption3\" | fzf --filter=option2'")
    print("   ✓ fzf instalado y funcionando")

    print("✅ Test de configuración de paquetes comunes completado exitosamente!")
  '';
}
