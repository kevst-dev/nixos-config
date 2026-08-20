# =============================================================================
# Sagan (Lenovo ThinkCentre M73 Tiny) - Hardware configuration
# =============================================================================
# ⚠️ GENERADO en el equipo con `nixos-generate-config`.
# ▶ ACTUALIZAR AQUÍ si tu disco/directorio raíz difiere:
#   * `device` del filesystem "/" → reemplazar `/dev/sda` por tu partición raíz
#     (p.ej. `/dev/disk/by-uuid/<uuid-real>` de `lsblk -f`).
#   * `boot.loader.grub.device` en hosts/sagan/boot.nix → mismo ajuste.
# =============================================================================
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fabc59b3-4bab-4ce3-bf0c-c4aa0af6edd2";
    fsType = "ext4";
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
