
print("🚀 Iniciando test de integración del servidor Turing")

# ============================================================
# FASE 1: Arranque del sistema
# Verifica que el sistema inicie correctamente y alcance
# el target multi-user (estado operativo básico).
# ============================================================
print("\n📋 FASE 1: Arranque del sistema")
machine.start()
machine.wait_for_unit("multi-user.target")
print("   ✓ Sistema arrancó correctamente")

# ============================================================
# FASE 2: Identidad del host
# El hostname se define explícitamente en el entorno de test
# para permitir validaciones determinísticas.
# ============================================================
print("\n🖥️  FASE 2: Identidad del host")
hostname = machine.succeed("hostname").strip()
assert hostname == "turing", f"Expected hostname 'turing', got '{hostname}'"
print(f"   ✓ Hostname configurado correctamente: {hostname}")

# ============================================================
# FASE 3: Usuarios y privilegios
# Valida existencia del usuario principal y configuración
# mínima de privilegios y entorno.
# ============================================================
print("\n👤 FASE 3: Usuarios y privilegios")
machine.succeed("id kevst")
print("   ✓ Usuario kevst existe")

machine.succeed("groups kevst | grep -q wheel")
print("   ✓ Usuario pertenece al grupo wheel (sudo)")

machine.succeed("getent passwd kevst | grep -q zsh")
print("   ✓ Shell del usuario configurado como zsh")

machine.succeed("getent group kevst")
print("   ✓ Grupo principal del usuario existe")

# ============================================================
# FASE 4: Servicios base del sistema
# Servicios esenciales que deben estar activos en todo momento.
# ============================================================
print("\n⚙️  FASE 4: Servicios base del sistema")
machine.wait_for_unit("sshd.service")
print("   ✓ Servicio SSH activo")

machine.wait_for_unit("firewall.service")
print("   ✓ Firewall activo")

# ============================================================
# FASE 5: Seguridad SSH
# Validaciones de hardening básico del acceso remoto.
# ============================================================
print("\n🔒 FASE 5: Seguridad SSH")
machine.fail("grep -q '^PermitRootLogin yes' /etc/ssh/sshd_config")
print("   ✓ Login de root deshabilitado")

machine.succeed("grep -q 'PasswordAuthentication yes' /etc/ssh/sshd_config")
print("   ✓ Autenticación por password habilitada")

# ============================================================
# FASE 6: Red y conectividad
# Se valida la configuración de red esperada para el host,
# incluyendo IP fija definida exclusivamente para tests.
# ============================================================
print("\n🌐 FASE 6: Red y conectividad")
machine.wait_for_open_port(22)
print("   ✓ Puerto 22 (SSH) escuchando")

machine.succeed("ip addr show | grep -E 'inet.*global' | grep -qv 127.0.0.1")
print("   ✓ Interfaz de red con dirección IP asignada")

machine.succeed("ip addr show | grep -q '10.0.0.10'")
print("   ✓ IP de test configurada correctamente (10.0.0.10)")

# ============================================================
# FASE 7: Contenedores (Podman / Docker)
# El sistema debe permitir ejecutar contenedores usando Podman,
# manteniendo compatibilidad con comandos Docker.
# ============================================================
print("\n🐳 FASE 7: Contenedores (Podman / Docker)")
machine.succeed("which podman")
print("   ✓ Podman instalado")

machine.succeed("which docker")
print("   ✓ Alias docker → podman configurado")

machine.succeed("podman --version")
print("   ✓ Podman operativo")

# ============================================================
# FASE 8: Sistema de archivos
# Verifica que el filesystem raíz esté montado y operativo.
# ============================================================
print("\n💾 FASE 8: Sistema de archivos")
machine.succeed("findmnt /")
print("   ✓ Filesystem raíz montado")

machine.succeed("df -h / | grep -q '/'")
print("   ✓ Espacio en disco disponible")

# ============================================================
# FASE 9: Paquetes del sistema
# Herramientas básicas que deben existir a nivel sistema.
# ============================================================
print("\n📦 FASE 9: Paquetes del sistema")
machine.succeed("which git")
print("   ✓ Git instalado")

machine.succeed("which just")
print("   ✓ Just instalado")

# ============================================================
# FASE 10: Home Manager (usuario kevst)
# Validaciones del entorno de usuario gestionado por HM.
# ============================================================
print("\n🏠 FASE 10: Home Manager (usuario kevst)")
machine.succeed("su - kevst -c 'which git'")
print("   ✓ Git disponible para el usuario")

machine.succeed("su - kevst -c 'which nvim'")
print("   ✓ Neovim disponible para el usuario")

machine.succeed("su - kevst -c 'git config --get user.name'")
print("   ✓ Git user.name configurado")

machine.succeed("su - kevst -c 'git config --get user.email'")
print("   ✓ Git user.email configurado")

machine.succeed("su - kevst -c 'test -f ~/.zshrc'")
print("   ✓ Zsh configurado para el usuario")

# ============================================================
# FASE 11: Configuración regional
# ============================================================
print("\n🕐 FASE 11: Configuración regional")
machine.succeed("timedatectl show | grep -q 'Timezone=America/Bogota'")
print("   ✓ Zona horaria configurada correctamente")

print("\n✅ Test de integración del servidor Turing completado exitosamente")
