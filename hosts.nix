# ============================================================================
# Definición de hosts - FLEET HOST DEFINITIONS
# Fuente única de verdad para toda la información del host
# ============================================================================
# NOTA: La configuración de red (IP estática vs DHCP) se maneja en el módulo
# networking.nix. Los valores aquí son parámetros que se pasan a ese módulo.
{
  # WSL: Entorno de desarrollo en Windows (Linux dentro de Windows)
  wsl = {
    ip = null; # Dinamic IP
    username = "kevst";
    tags = ["dev"];
  };

  # Turing: Servidor self-hosted principal
  turing = {
    ip = "192.168.20.79";
    username = "kevst";
    tags = ["server"];
  };

  # Stallman: Laptop de desarrollo personal
  stallman = {
    ip = null; # Dinamic IP
    username = "kevst";
    tags = ["laptop" "dev"];
  };
}
