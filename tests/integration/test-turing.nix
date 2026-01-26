{self, ...}: let
  hosts = import ../../hosts.nix;
  host = {
    ip = "10.0.0.10"; # IP fija para test, se puede cambiar según necesidades
    inherit (hosts.turing) username;
    tags = ["tests" "server"];

    # Este no es propio de host si no que en produccion se obtiene
    # de el hostname del sistema, pero en test se define aqui para
    # facilitar la verificacion
    hostname = "turing";
  };

  # Configuración de test re-evaluada con parámetros de test
  testConfig = self.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit (host) hostname ip username;
      inherit (self) inputs;
    };

    # Reusar EXACTAMENTE los módulos del flake principal
    inherit (self.nixosConfigurations.turing._module.args) modules;
  };
in {
  name = "turing-simple-test";

  # Permitir que los nodes modifiquen nixpkgs.* options (necesario para allowUnfree)
  node.pkgsReadOnly = false;

  # Los specialArgs ya están definidos en testConfig, _module.args usa valores de test
  defaults = {
    _module.args = {
      # hostname = "turing";
      inherit (host) hostname ip username;
      inherit (self) inputs;
    };
  };

  nodes.machine = {
    # Importar configuración re-evaluada con valores de test
    imports = testConfig._module.args.modules;

    # Configurar enlace virtual: mapear eth1 -> enp2s0 para que el módulo networking
    # configure el nombre de interfaz esperado en lugar de eth1 que usa la VM por defecto
    # Esto permite testear el módulo networking completo sin modificar código fuente.
    # enp2s0 es el nombre esperado en Turing y que se encuentra en el archivo de
    # configuracion hosts.nix
    systemd.network.links."10-enp2s0" = {
      matchConfig.PermanentMACAddress = "52:54:00:12:01:01"; # MAC address que QEMU asigna a eth1
      linkConfig.Name = "enp2s0"; # Forzar nombre de interfaz esperado por el módulo networking
    };
  };

  testScript = ''
    print("🚀 Iniciando test de integración del servidor Turing...")

    # FASE 1: Arranque del sistema
    print("\n📋 FASE 1: Verificando arranque del sistema...")
    machine.start()
    machine.wait_for_unit("multi-user.target")
    print("   ✓ Sistema arrancó correctamente")

    hostname = machine.succeed("hostname").strip()
    assert hostname == "turing", f"Expected hostname 'turing', got '{hostname}'"
    print(f"   ✓ Hostname configurado: {hostname}")

    # FASE 2: Verificar usuarios y grupos
    print("\n👤 FASE 2: Verificando configuración de usuarios...")
    machine.succeed("id kevst")
    print("   ✓ Usuario kevst existe")

    machine.succeed("groups kevst | grep -q wheel")
    print("   ✓ Usuario en grupo wheel (sudo)")

    machine.succeed("getent passwd kevst | grep -q zsh")
    print("   ✓ Shell configurado como zsh")

    # Verificar que el grupo principal del usuario existe
    machine.succeed("getent group kevst")
    print("   ✓ Grupo principal 'kevst' existe")

    # FASE 3: Verificar servicios del sistema
    print("\n⚙️  FASE 3: Verificando servicios del sistema...")
    machine.wait_for_unit("sshd.service")
    print("   ✓ SSH daemon está activo")

    machine.wait_for_unit("firewall.service")
    print("   ✓ Firewall está activo")

    # FASE 4: Verificar seguridad SSH
    print("\n🔒 FASE 4: Verificando configuración de seguridad SSH...")
    machine.fail("grep -q '^PermitRootLogin yes' /etc/ssh/sshd_config")
    print("   ✓ Root login deshabilitado")

    machine.succeed("grep -q 'PasswordAuthentication yes' /etc/ssh/sshd_config")
    print("   ✓ Autenticación por password habilitada (requerido para acceso remoto)")

    # FASE 5: Verificar puertos de red
    print("\n🌐 FASE 5: Verificando configuración de red y puertos...")
    machine.wait_for_open_port(22)
    print("   ✓ Puerto 22 (SSH) escuchando")

    # Debug: Mostrar configuración de red actual
    print("   🔍 Debug: Configuración de red actual:")
    result = machine.succeed("ip addr show")
    print(f"   IP addresses: {result}")
    result = machine.succeed("ip route show")
    print(f"   Routes: {result}")
    result = machine.succeed("cat /etc/resolv.conf")
    print(f"   Resolv.conf: {result}")
    result = machine.succeed("hostname")
    print(f"   Hostname: {result}")

    # Verificar conectividad de red básica (buscar cualquier interfaz activa)
    machine.succeed("ip addr show | grep -E 'inet.*global' | grep -qv '127.0.0.1'")
    print("   ✓ Interfaz de red con dirección IP configurada")

    # Verificar que la IP de test esté configurada
    machine.succeed("ip addr show | grep -q '10.0.0.10'")
    print("   ✓ IP de test configurada correctamente (10.0.0.10)")

    # FASE 6: Verificar Podman y Docker
    print("\n🐳 FASE 6: Verificando contenedores (Podman/Docker)...")
    machine.succeed("which podman")
    print("   ✓ Podman está instalado")

    machine.succeed("which docker")
    print("   ✓ Alias docker -> podman configurado")

    machine.succeed("podman --version")
    print("   ✓ Podman funciona correctamente")

    # FASE 7: Verificar sistema de archivos
    print("\n💾 FASE 7: Verificando filesystem...")
    machine.succeed("findmnt /")
    print("   ✓ Filesystem raíz montado")

    machine.succeed("df -h / | grep -q '/'")
    print("   ✓ Espacio en disco disponible")

    # FASE 8: Verificar paquetes del sistema
    print("\n📦 FASE 8: Verificando paquetes del sistema...")
    machine.succeed("which git")
    print("   ✓ Git instalado (sistema)")

    machine.succeed("which just")
    print("   ✓ Just instalado (sistema)")

    # FASE 9: Verificar configuración de Home Manager
    print("\n🏠 FASE 9: Verificando configuración de Home Manager...")
    machine.succeed("su - kevst -c 'which git'")
    print("   ✓ Git disponible para usuario")

    machine.succeed("su - kevst -c 'which nvim'")
    print("   ✓ Neovim instalado para usuario")

    machine.succeed("su - kevst -c 'git config --get user.name'")
    print("   ✓ Git user.name configurado")

    machine.succeed("su - kevst -c 'git config --get user.email'")
    print("   ✓ Git user.email configurado")

    machine.succeed("su - kevst -c 'test -f ~/.zshrc'")
    print("   ✓ Zsh configurado para usuario")

    # FASE 10: Verificar configuración de zona horaria
    print("\n🕐 FASE 10: Verificando configuración regional...")
    machine.succeed("timedatectl show | grep -q 'Timezone=America/Bogota'")
    print("   ✓ Zona horaria: America/Bogota")

    print("\n✅ Test de integración del servidor Turing completado exitosamente!")
    print("   Todas las configuraciones verificadas correctamente.")
  '';
}
