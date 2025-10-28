-- Configuración del colorscheme Kanagawa Paper
-- NO usar lze para colorschemes: van en startupPlugins y configuración directa
-- (según template oficial de nixCats)
require("kanagawa-paper").setup({
	undercurl = true, -- habilitar subrayados ondulados
	transparent = false, -- no establecer color de fondo transparente
	gutter = false, -- usar fondo por defecto en gutter
	dimInactive = true, -- atenuar ventanas inactivas
	terminalColors = true, -- definir colores de terminal
	commentStyle = { italic = true }, -- estilo para comentarios
	functionStyle = { bold = false }, -- estilo para funciones
	keywordStyle = { italic = true }, -- estilo para palabras clave
	statementStyle = { bold = true }, -- estilo para declaraciones
	typeStyle = { bold = false }, -- estilo para tipos
	colors = { -- personalizar colores
		palette = {}, -- modificar paleta de colores
		theme = {}, -- modificar colores específicos del tema
	},
})

-- Usar tema oscuro por defecto (ink = oscuro, canvas = claro)
vim.cmd.colorscheme("kanagawa-paper-ink")

print("📜 Kanagawa Paper configurado correctamente!")
