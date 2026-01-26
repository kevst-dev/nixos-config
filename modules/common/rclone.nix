{pkgs, ...}:
################################################################################
# Proton Drive + rclone
#
# Este módulo instala rclone para permitir la conexión manual a Proton Drive.
# La configuración del remote NO se gestiona declarativamente, ya que requiere
# autenticación interactiva (login y 2FA).
#
# La configuración debe realizarse una vez por host.
################################################################################
#
# Pasos de configuración:
#
# 1. Iniciar sesión en el host y ejecutar: `rclone config`
#
# 2. Crear un nuevo remote:
#    - Tipo: protondrive
#    - Nombre sugerido: proton-drive
#
# 3. Cuando rclone pregunte por 2FA interactivo:
#    - Dejar el campo COMPLETAMENTE VACÍO
#    - NO introducir códigos temporales
#    - NO pegar secretos en este paso
#
# 4. Cuando rclone pregunte por 2FA (otp_secret_key):
#    - Abrir la app Aegis
#    - Copiar la URL completa del token (otpauth://totp/...)
#    - Extraer el valor de `secret=`
#    - Pegar el valor SIN:
#        - guiones
#        - espacios
#        - minúsculas
#      (solo caracteres A-Z y 2-7)
#
# 4. Completar el login interactivo cuando rclone lo solicite.
#
# 5. Verificar que el remote funciona correctamente:
#
#      `rclone listremotes`
#      `rclone lsd proton-drive:`
#
# 6. Para parámetros avanzados (manejo de duplicados, flags adicionales,
#    comportamiento del backend), consultar la documentación oficial:
#
#    https://rclone.org/protondrive/
#
################################################################################
{
  environment.systemPackages = [
    pkgs.rclone
  ];
}
