{ self, pkgs, lib, ... }:
let
  username = "kevst";
in
{
  name = "turing-simple-test";

  # Permitir que los nodes modifiquen nixpkgs.* options (necesario para allowUnfree)
  node.pkgsReadOnly = false;

  # Pasar specialArgs necesarios a todos los nodes
  defaults = {
    _module.args = {
      inherit username;
      inputs = self.inputs;
    };
  };

  nodes.machine = {
    # Importar configuración real de Turing
    imports = self.nixosConfigurations.turing._module.args.modules;
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    print("✓ Sistema arrancó correctamente")

    # Verificar que es el host Turing
    hostname = machine.succeed("hostname").strip()
    print(f"Hostname: {hostname}")
    assert hostname == "turing", f"Expected hostname 'turing', got '{hostname}'"
    print("✓ Hostname correcto: turing")

    # Verificar que SSH está habilitado (específico de Turing)
    machine.wait_for_unit("sshd.service")
    print("✓ SSH está habilitado")

    # Verificar que Podman está disponible (específico de Turing)
    machine.succeed("which podman")
    print("✓ Podman está instalado")

    # Verificar que el alias docker existe (dockerCompat = true en Turing)
    machine.succeed("which docker")
    print("✓ Docker alias está configurado")

    print("\n✅ Test exitoso: Es el host Turing")
  '';
}
