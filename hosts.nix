# ============================================================================
# FLEET HOST DEFINITIONS
# Single source of truth for all host information
# ============================================================================
# TODO: Configurar uso de IPs dinámicas en la configuración de red (actualmente no se usan, solo se pasan como params)
{
  # Hosts actuales
  wsl = {
    ip = null; # Dynamic IP
    user = "kevst";
    tags = ["dev"];
  };

  turing = {
    ip = "192.168.1.100";
    user = "kevst";
    tags = ["server"];
  };
}
