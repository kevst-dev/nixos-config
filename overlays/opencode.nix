# overlay/opencode.nix — Parche temporal para opencode + glibc 2.42
#
# PROBLEMA:
#   El binario de opencode (compilado con Bun --single) declara dependencias
#   a libpthread.so.0 y libdl.so.2 en su sección DT_NEEDED. A partir de
#   glibc 2.34 estas bibliotecas se fusionaron dentro de libc.so.6, pero
#   se mantuvieron como stubs de compatibilidad. En glibc 2.42 el dynamic
#   linker (ld-linux-x86-64.so.2) crashea con SEGV al procesar estos stubs,
#   provocando que opencode ni siquiera arranque.
#
# REFERENCIAS:
#   - https://github.com/anomalyco/opencode/issues/13551 (Fedora/glibc 2.42)
#   - https://github.com/anomalyco/opencode/issues/26846 (NixOS+WSL)
#
# SOLUCIÓN (2 partes):
#   1. Parchear el script de build para que ignore el smoke test (que también
#      crashea con glibc 2.42, abortando la compilación antes de terminarla).
#   2. Eliminar las referencias a libpthread.so.0 y libdl.so.2 del binario
#      con patchelf. Los símbolos que opencode necesita de estas bibliotecas
#      ya están disponibles en libc.so.6, por lo que el binario funciona
#      correctamente sin ellas.
#
# CUÁNDO QUITAR ESTE OVERLAY:
#   Cuando upstream de opencode (o Bun) publique una versión que ya no
#   declare estas dependencias obsoletas, este overlay se vuelve inocuo
#   (patchelf simplemente no encuentra qué remover y no hace nada).
#
#   Para verificar:  readelf -d <opencode> | grep NEEDED
#   Si ya no aparecen libpthread ni libdl, el overlay se puede eliminar.
final: prev: {
  opencode = prev.opencode.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.patchelf];

    # Parche 1: el smoke test del build ejecuta el binario recién compilado
    # y crashea con glibc 2.42. Lo deshabilitamos para que el build continúe.
    postPatch =
      (old.postPatch or "")
      + ''
        echo "opencode overlay: deshabilitando smoke test (incompatible glibc 2.42)..."
        substituteInPlace packages/opencode/script/build.ts \
          --replace-fail 'process.exit(1)' \
                         'console.warn("Smoke test skipped (opencode overlay: glibc 2.42 compatibility)")'
      '';

    # Parche 2: el binario declara NEEDED a libpthread.so.0 y libdl.so.2,
    # que en glibc 2.42 provocan SEGV en ld-linux. Las reemplazamos con
    # libc.so.6 (que desde glibc 2.34 incluye todos los símbolos de ambas).
    # Usamos --replace-needed (no --remove-needed) para mantener la coherencia
    # del versionado ELF (VERNEED) y evitar el assertion en
    # dl-version.c: _dl_check_map_versions.
    postInstall =
      ''
        echo "opencode overlay: reemplazando dependencias libpthread/libdl → libc..."
        patchelf --replace-needed libpthread.so.0 libc.so.6 \
                 --replace-needed libdl.so.2 libc.so.6 \
                 "$out/bin/.opencode-wrapped"
      ''
      + (old.postInstall or "");
  });
}
