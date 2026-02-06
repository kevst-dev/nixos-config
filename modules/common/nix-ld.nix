{pkgs, ...}: {
  ##################################################################################################################
  #
  # nix-ld: Soporte para binarios dinámicos externos en NixOS
  #
  ##################################################################################################################
  #
  # QUE PROBLEMA RESUELVE
  # ==============================================================================================================
  #
  # NixOS NO es FHS-compliant (Filesystem Hierarchy Standard). En Linux tradicional,
  # los binarios precompilados esperan encontrar el "dynamic linker" en:
  #
  #   /lib64/ld-linux-x86-64.so.2
  #
  # Pero en NixOS este archivo NO existe. El linker está en /nix/store/...-glibc/lib/
  # Esto causa que binarios descargados de internet fallen con:
  #
  #   "No such file or directory" (aunque el archivo sí existe)
  #
  # COMO LO RESUELVE NIX-LD
  # ==============================================================================================================
  #
  # nix-ld crea un "shim" (intermediario) en /lib64/ld-linux-x86-64.so.2 que:
  # 1. Intercepta las llamadas al dynamic linker
  # 2. Redirige al linker real de NixOS en /nix/store/
  # 3. Proporciona las librerías configuradas en NIX_LD_LIBRARY_PATH
  #
  # Esto permite ejecutar binarios externos SIN modificarlos (sin patchelf).
  #
  # CASOS DE USO
  # ==============================================================================================================
  #
  # - uv/pip: Gestores de paquetes Python que descargan binarios precompilados
  # - npm/node: Paquetes con bindings nativos
  # - IDEs propietarios: VSCode, JetBrains, etc.
  # - Binarios de terceros: Herramientas CLI descargadas manualmente
  #
  # SEGURIDAD
  # ==============================================================================================================
  #
  # nix-ld es "complementario, no invasivo":
  # - Solo afecta binarios que buscan el linker en /lib64/
  # - NO modifica paquetes de nixpkgs (usan su propio linker de /nix/store/)
  # - NO introduce vulnerabilidades (el shim solo redirige, no ejecuta código)
  #
  # REFERENCIAS
  # ==============================================================================================================
  #
  # - Wiki oficial: https://wiki.nixos.org/wiki/Nix-ld
  # - Repositorio: https://github.com/nix-community/nix-ld
  # - Packaging binaries: https://nixos.wiki/wiki/Packaging/Binaries
  #
  ##################################################################################################################

  programs.nix-ld = {
    enable = true;

    # Librerías comunes que los binarios dinámicos suelen necesitar.
    # Estas se exponen via NIX_LD_LIBRARY_PATH para que el linker las encuentre.
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++ - requerido por casi todo código C++
      zlib # compresión - muy común en Python/Node
      openssl # SSL/TLS - conexiones HTTPS
    ];
  };
}
