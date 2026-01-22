# NixOS Fleet Management - Configuración Personal

Esta configuración gestiona múltiples hosts NixOS usando Colmena para despliegue,
con Home Manager para configuraciones de usuario.

## Arquitectura

- **Hosts locales:** wsl (desarrollo en WSL2)
- **Hosts remotos:** turing (servidor)
- **Gestión:** Colmena para despliegue, Home Manager para usuarios
- **Testing:** VMs NixOS para validación

## Configuración Inicial de un Nuevo Host

### 1. Instalar NixOS en la Máquina

Antes de conectar un host a Colmena, debe tener NixOS instalado y configurado básicamente.

#### Opción A: Instalación Fresca
1. Descargar imagen NixOS: https://nixos.org/download/
2. Crear USB bootable: `dd if=nixos.iso of=/dev/sdX bs=4M`
3. Boot desde USB, seguir instalador gráfico
4. Configurar particiones, usuario, hostname
5. Generar configuración inicial: `sudo nixos-generate-config`

#### Opción B: Usando nixos-anywhere (Recomendado para Servidores)
```bash
# Instalar nixos-anywhere
nix-shell -p nixos-anywhere

# Desplegar a máquina remota (requiere SSH temporal)
nixos-anywhere --flake .#turing root@turing-ip
```

### 2. Configuración Básica Post-Instalación

Después de instalar NixOS:

1. **Habilitar SSH:**
   ```nix
   # En configuration.nix temporal
   services.openssh.enable = true;
   users.users.root.openssh.authorizedKeys.keys = [
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... tu_clave_pública"
   ];
   ```

2. **Aplicar configuración inicial:**
   ```bash
   sudo nixos-rebuild switch
   ```

3. **Verificar conectividad:**
   ```bash
   ssh root@turing-ip  # Debe funcionar sin password
   ```

### 3. Agregar Host a la Colmena

Una vez que la máquina tenga NixOS básico:

1. **Agregar entrada en `hosts.nix`:**
   ```nix
   turing = {
     ip = "192.168.1.100";
     user = "kevst";
     tags = ["server"];
   };
   ```

2. **Crear configuración en `hosts/turing/default.nix`**

3. **Configurar Home Manager en `users/kevst/turing.nix`**

4. **Probar conexión:**
   ```bash
   colmena apply --on turing --reboot=false
   ```

## Desarrollo Local

### Entorno de Desarrollo
```bash
# Entrar al shell de desarrollo
nix develop

# Construir configuración local
colmena build --on wsl
```

### Comandos Útiles
- `just deploy` - Desplegar a todos los hosts
- `just deploy-turing` - Solo al servidor
- `just test-unit-all` - Ejecutar tests

## Estructura del Repositorio

```
├── flake.nix                    # Configuración principal
├── hosts.nix                    # Metadatos de hosts
├── justfile                     # Tareas de desarrollo
├── hosts/
│   ├── wsl/default.nix          # Config sistema WSL
│   └── turing/default.nix       # Config sistema Turing
├── users/kevst/
│   ├── wsl.nix                  # Config usuario WSL
│   └── turing.nix               # Config usuario Turing
└── tests/
    └── unit/                    # Tests de integración
```

## Troubleshooting

### Problemas Comunes

**SSH falla:**
- Verificar claves: `ssh-copy-id user@host`
- Firewall: `sudo ufw allow ssh` en el host remoto

**Build falla:**
- Actualizar flake: `nix flake update`
- Verificar sintaxis: `nix flake check`

**Despliegue falla:**
- Logs: `colmena apply --verbose`
- Rollback: `colmena apply --on host --rollback`