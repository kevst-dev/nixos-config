# ============================================================================
# Definición de hosts - FLEET HOST DEFINITIONS
# Fuente única de verdad para toda la información del host
# ============================================================================
# NOTA: La configuración de red (IP estática vs DHCP) se maneja en el módulo
# networking.nix. Los valores aquí son parámetros que se pasan a ese módulo.
#
# TODO: Implementar Proton Drive para backup cifrado ($50/año):
# - Rclone para conexión a Proton Drive
# - Restic para backups cifrados y automatizados
# - Doble copia: local en turing + nube
# - En el futuro una copia en mi NAS en casa
{
  # Hosts actuales
  wsl = {
    ip = null; # Dynamic IP
    username = "kevst";
    tags = ["dev"];
  };

  turing = {
    ip = "192.168.1.100";
    username = "kevst";
    tags = ["server"];
  };
}
