{pkgs, ...}: {
  # Audio con PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # Persistencia de ALSA
  hardware.alsa.enablePersistence = true;

  # Paquetes de audio
  environment.systemPackages = with pkgs; [
    alsa-firmware
    alsa-oss
    pavucontrol
  ];
}
