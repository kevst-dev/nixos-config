# Configuración Modular de NixOS

Este repositorio contiene una **configuración modular de NixOS basada en flakes**, diseñada para **gestionar múltiples hosts** e integrar **Home Manager** de forma limpia y reutilizable.

El enfoque prioriza:

* Separación clara de responsabilidades
* Reutilización de configuraciones entre hosts y usuarios
* Facilidad de pruebas (tests en VMs)
* Herramientas de desarrollo y control de calidad (pre-commit)

---

## Inicio rápido

1. Clonar el repositorio (habitualmente en `/home/{user}`):

```bash
git clone https://github.com/kevst-dev/nixos-config.git
cd nixos-config
```

2. Ejecutar las verificaciones de calidad (pre-commit, linting y formato):

```bash
just check
```

3. Desplegar la configuración según el host:

```bash
# Despliegue en WSL
just wsl

# Despliegue en el servidor "turing"
just turing
```

---

## Vista general de la arquitectura

### Estructura de directorios

```
├── flake.nix                    # Flake principal
├── justfile                     # Comandos específicos del proyecto (just)
├── hosts/                       # Configuración a nivel de sistema por host
│   ├── wsl/                     # Host WSL
│   └── turing/                  # Servidor turing
├── modules/                     # Módulos de sistema compartidos
├── home/                        # Configuración de Home Manager
│   ├── core.nix                 # Base de Home Manager
│   └── programs/                # Programas reutilizables (nvim, git, zsh, etc.)
├── dotfiles/                    # Dotfiles crudos
├── users/                       # Configuración por usuario y por host
├── tests/                       # Tests unitarios e integración en VMs
├── dev/                         # Entorno de desarrollo (pre-commit)
└── docs/                        # Documentación adicional
```

---

## Descripción de los componentes

### `hosts/`

Contiene la **configuración de NixOS a nivel de sistema** para cada host.
Aquí se definen aspectos específicos del entorno, como servicios, hardware, red o particularidades de WSL vs servidores físicos.

---

### `modules/`

Incluye **módulos de sistema reutilizables**, aplicables a uno o varios hosts.
Permite evitar duplicación y mantener una base común de configuración.

---

### `home/`

Agrupa la configuración de **Home Manager**, organizada de forma modular:

* `home/programs/`:
  Piezas reutilizables de configuración (por ejemplo: `nvim`, `git`, `zsh`, `starship`).
* `home/core.nix`:
  Configuración base de Home Manager que luego es importada por cada usuario.

Estas piezas se integran desde los módulos de cada usuario definidos en `users/`.

---

### `users/`

Aquí se **componen las configuraciones de Home Manager por usuario y por host**.

Estructura típica:

* `users/${user}/common.nix`: Configuración compartida por el usuario en todos los hosts (por ejemplo: `git`, `zsh`, configuración básica del shell).

* `users/${user}/wsl.nix`: Configuración específica para WSL.

* `users/${user}/turing.nix`: Configuración específica para el servidor.

Ejemplo de criterio:

* `git` se utiliza en todos los hosts → `common.nix`
* `podman` solo se utiliza en el servidor → `turing.nix`

Este enfoque permite mantener **una separación clara entre lo común y lo específico**.

---

### `dotfiles/`

Contiene **dotfiles crudos**, gestionados mediante **enlaces simbólicos** desde Nix y Home Manager.

Ventajas de este enfoque:

* Los dotfiles pueden reutilizarse en otros sistemas sin depender de Nix
* Los cambios en los archivos se reflejan inmediatamente
* No es necesario reconstruir el sistema Nix para modificar configuraciones simples

---

### `tests/`

Incluye pruebas automatizadas:

* **Tests unitarios** en VMs para componentes individuales
* **Tests de integración** en VMs para cada host

Esto permite validar cambios antes de desplegarlos en entornos reales.

---

### `dev/`

Flake dedicado al **entorno de desarrollo**, que incluye herramientas para:

* Pre-commit hooks
* Linting
* Formateo
* Verificaciones de calidad

---

### `docs/`

Documentación detallada sobre uso, extensión y troubleshooting del proyecto. Incluye guías de estilo de commits y otras referencias.

---

## Documentación adicional

- Coding guidelines:
  - [Estilo de commits](docs/coding-guidelines/commit_style.md): Estilo de commits y convenciones.

---
