{home-manager}: {
  name = "Zsh configuration test";

  nodes = {
    machine = {pkgs, ...}: {
      # Importar Home Manager como módulo de NixOS
      imports = [home-manager.nixosModules.home-manager];

      # Instalar zsh a nivel sistema para verificación
      environment.systemPackages = [pkgs.zsh];

      # Configurar zsh como shell válido
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
          imports = [../../../../home/programs/zsh.nix];
          home.stateVersion = "24.05";
        };
      };
    };
  };

  testScript = ''
    print("🚀 Iniciando test de configuración de Zsh...")

    machine.wait_for_unit("multi-user.target")

    print("📦 Verificando que zsh esté instalado...")
    machine.succeed("zsh --version")

    print("👤 Verificando que zsh funcione para el usuario...")
    machine.succeed("su - testuser -c 'zsh --version'")

    print("⚙️  Verificando que zsh esté habilitado en Home Manager...")
    machine.succeed("su - testuser -c 'test -f ~/.zshrc'")
    print("   ✓ Archivo .zshrc existe")

    print("🔧 Verificando configuración de variables de entorno...")
    machine.succeed("su - testuser -c 'zsh -c \"echo \\$DOTFILES_DIR\" | grep -q nixos-config/dotfiles'")
    print("   ✓ DOTFILES_DIR configurado correctamente")

    machine.succeed("su - testuser -c 'zsh -c \"echo \\$ZSH_DIR\" | grep -q dotfiles/zsh'")
    print("   ✓ ZSH_DIR configurado correctamente")

    print("🔌 Verificando plugins de zsh...")
    machine.succeed("su - testuser -c 'grep -q \"zsh-syntax-highlighting\" ~/.zshrc'")
    print("   ✓ Plugin zsh-syntax-highlighting cargado")

    machine.succeed("su - testuser -c 'grep -q \"zsh-autosuggestions\" ~/.zshrc'")
    print("   ✓ Plugin zsh-autosuggestions cargado")

    machine.succeed("su - testuser -c 'grep -q \"zsh-vi-mode\" ~/.zshrc'")
    print("   ✓ Plugin zsh-vi-mode cargado")

    machine.succeed("su - testuser -c 'grep -q \"zsh-you-should-use\" ~/.zshrc'")
    print("   ✓ Plugin zsh-you-should-use cargado")

    machine.succeed(
      "su - testuser -c 'test -d ~/.nix-profile/share/zsh/site-functions && find ~/.nix-profile/share/zsh/site-functions -maxdepth 1 -name \"_*\" | grep -q .'"
    )
    print("   ✓ Completions de paquetes disponibles en site-functions (zsh-completions)")

    print("🧪 Probando funcionalidad básica de zsh...")
    machine.succeed("su - testuser -c 'zsh -c \"echo test\"' | grep -q 'test'")
    print("   ✓ Zsh ejecuta comandos correctamente")

    # Verificar que el shell del usuario sea zsh
    print("🔍 Verificando shell por defecto...")
    machine.succeed("getent passwd testuser | grep -q zsh")
    print("   ✓ Zsh configurado como shell por defecto")

    # Probar funcionalidad interactiva básica
    print("🎮 Probando funcionalidad interactiva...")
    machine.succeed("su - testuser -c 'zsh -i -c \"echo interactive_test\"' | grep -q 'interactive_test'")
    print("   ✓ Modo interactivo funciona correctamente")

    print("✅ Test de configuración de Zsh completado exitosamente!")
  '';
}
