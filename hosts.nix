# ============================================================================
# FLEET HOST DEFINITIONS
# Single source of truth for all host information
# ============================================================================
# TODO: Una idea que me resulta interesante, seria pagar Proton Drive que es unos $50 dolares anuales y en el hacer mi segunda copia de seguridad cifrada, tendria una copia en el propio servidor y otra en la nube. la conexion al Proton Drive se puede hacer con Rclone, Rclone conectarlo con Restic y Restic hacer las copias de seguridad cifradas y automatizadas.
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
