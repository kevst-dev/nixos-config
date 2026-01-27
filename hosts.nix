# ============================================================================
# Definición de hosts - FLEET HOST DEFINITIONS
# Fuente única de verdad para toda la información del host
# ============================================================================
# NOTA: La configuración de red (IP estática vs DHCP) se maneja en el módulo
# networking.nix. Los valores aquí son parámetros que se pasan a ese módulo.
{
  # Hosts actuales
  wsl = {
    ip = null; # Dynamic IP
    username = "kevst";
    tags = ["dev"];
  };

  turing = {
    ip = "192.168.20.79";
    username = "kevst";
    tags = ["server"];
  };
}
