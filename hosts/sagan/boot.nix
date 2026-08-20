{pkgs, ...}: {
  # =========================================================================
  # Boot: GRUB legacy (BIOS/MBR) - coincide con la instalación actual del M73
  # =========================================================================
  # La instalación existente usa GRUB en /dev/sda (MBR, sin /boot separado,
  # root en la misma partición). Mantenemos el mismo esquema para no tocar la
  # tabla de particiones ni el proceso de arranque.
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
      # Un solo sistema operativo: no hacer os-prober
      useOSProber = false;
    };
  };

  # FIJAR LÍNEA DE KERNEL: el módulo out-of-tree r8125 se compila contra el
  # kernel. Fijando la línea evitamos que un bump rompa la NIC 2.5G en cada
  # update de nixos-unstable. Migrar deliberadamente cuando se quiera.
  boot.kernelPackages = pkgs.linuxPackages_6_12;
}
