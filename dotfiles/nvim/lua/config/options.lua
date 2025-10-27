-- ==========================================================================
-- CONFIGURACIÓN DE OPCIONES DE NEOVIM
-- ==========================================================================

-- Leader key
vim.g.mapleader = " "
vim.g.snippets = "luasnip"

local options = vim.o

-- ==========================================================================
-- INTERFAZ Y VISUALIZACIÓN
-- ==========================================================================

-- Números de línea
options.number = true           -- Mostrar números de línea
options.relativenumber = true   -- Números relativos para navegación

-- Colores y tema
options.termguicolors = true    -- Soporte para colores de 24-bit
options.signcolumn = "yes"      -- Siempre mostrar columna de signos

-- Líneas y columnas guía
options.cursorline = true       -- Resaltar línea actual
options.colorcolumn = "88"      -- Línea guía en columna 80
options.scrolloff = 4           -- Líneas mínimas arriba/abajo del cursor
options.sidescrolloff = 4       -- Columnas mínimas izq/der del cursor

-- UI y estado
options.showmode = false        -- No mostrar modo (lo maneja lualine)
options.laststatus = 3          -- Barra de estado global
options.cmdheight = 1           -- Altura de línea de comandos

-- ==========================================================================
-- TEXTO Y EDICIÓN
-- ==========================================================================

-- Indentación
options.expandtab = true        -- Usar espacios en lugar de tabs
options.tabstop = 4             -- Ancho visual de tab
options.softtabstop = 4         -- Espacios que cuenta como tab al editar
options.shiftwidth = 4          -- Espacios para autoindent
options.smartindent = true      -- Indentación inteligente

-- Ajuste de líneas
options.wrap = true             -- Ajustar líneas largas
options.linebreak = true        -- Romper en palabras, no caracteres
options.textwidth = 80          -- Ancho máximo de línea

-- Caracteres especiales
options.list = true             -- Mostrar caracteres invisibles
options.listchars = "tab:\\ ,trail:-"  -- Cómo mostrar tabs y espacios

-- ==========================================================================
-- BÚSQUEDA
-- ==========================================================================

options.hlsearch = false        -- No resaltar resultados de búsqueda
options.incsearch = true        -- Búsqueda incremental
options.ignorecase = true       -- Ignorar mayúsculas al buscar
options.smartcase = true        -- Sensible a mayúsculas si hay mayúsculas

-- ==========================================================================
-- ARCHIVOS Y BUFFERS
-- ==========================================================================

options.hidden = true           -- Permitir buffers ocultos sin guardar
options.swapfile = false        -- No crear archivos .swp
options.undofile = true         -- Mantener historial de deshacer
options.autowrite = true        -- Guardar automáticamente al cambiar buffer

-- ==========================================================================
-- SISTEMA Y INTEGRACIÓN
-- ==========================================================================

-- Mouse y clipboard
options.mouse = "a"             -- Habilitar mouse en todos los modos
options.clipboard = "unnamedplus"  -- Usar clipboard del sistema

-- Ventanas
options.splitbelow = true       -- Nuevos splits horizontales abajo
options.splitright = true       -- Nuevos splits verticales a la derecha

-- Performance
options.updatetime = 50         -- Tiempo para trigger eventos (ms)
options.errorbells = false      -- Sin sonidos de error

-- ==========================================================================
-- WSL CLIPBOARD INTEGRATION
-- ==========================================================================

vim.g.clipboard = {
  name = "win32yank-wsl",
  copy = {
    ["+"] = "win32yank.exe -i --crlf",
    ["*"] = "win32yank.exe -i --crlf"
  },
  paste = {
    ["+"] = "win32yank.exe -o --crlf",
    ["*"] = "win32yank.exe -o --crlf"
  },
  cache_enable = 0,
}

print("⚙️  Opciones configuradas correctamente")