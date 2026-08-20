_: {
  # =========================================================================
  # SSH para acceso remoto al router
  # =========================================================================
  # Durante la Fase 1 se usa autenticación por usuario/clave (igual que
  # Turing). Cuando el router esté en producción, evaluar pasar a llaves.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };
}
