{_}: {
  # Habilitar SSH para acceso remoto
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      # Añadir hmac-sha2-256 para compatibilidad con Cloudflare browser rendering
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
        "hmac-sha2-256" # Requerido para Cloudflare Access SSH browser rendering
      ];
    };
  };
}