{self, ...}: let
  hosts = import ../../hosts.nix;
  host = {
    ip = "10.0.0.10"; # IP fija para test, se puede cambiar según necesidades
    inherit (hosts.turing) username;
    tags = ["tests" "server"];

    # En producción el hostname proviene del sistema real.
    # En tests se define explícitamente para permitir validaciones
    # deterministas.
    hostname = "turing";
  };

  # Configuración de test re-evaluada con parámetros de test
  testConfig = self.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit (host) hostname ip username;
      inherit (self) inputs;
    };

    # Usar los módulos del flake principal
    inherit (self.nixosConfigurations.turing._module.args) modules;
  };
in {
  name = "turing-simple-test";

  # Permitir que los nodes modifiquen nixpkgs.* options (necesario para allowUnfree)
  node.pkgsReadOnly = false;

  # Los specialArgs ya están definidos en testConfig, _module.args usa valores de test
  defaults = {
    _module.args = {
      inherit (host) hostname ip username;
      inherit (self) inputs;
    };
  };

  nodes.machine = {
    # Importar configuración re-evaluada con valores de test
    imports = testConfig._module.args.modules;

    # Configurar enlace virtual:
    # Mapea la interfaz virtual de QEMU (eth1) al nombre esperado por el host real.
    # Esto permite reutilizar el módulo de networking sin introducir condicionales
    # específicas para entorno de test.
    systemd.network.links."10-enp2s0" = {
      matchConfig.PermanentMACAddress = "52:54:00:12:01:01"; # MAC address que QEMU asigna a eth1
      linkConfig.Name = "enp2s0"; # Forzar nombre de interfaz esperado por el módulo networking
    };
  };

  testScript = builtins.readFile ./test-turing.py;
}
