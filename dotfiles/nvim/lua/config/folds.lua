-- ============================================================================
-- CONFIGURACIÓN DE FOLDING NATIVO CON TREESITTER
-- ============================================================================
-- Este archivo configura el sistema de plegado de código utilizando las
-- capacidades nativas de Neovim con treesitter como proveedor principal
-- y fallback inteligente a indent cuando treesitter no está disponible.

-- =========================
-- CONFIGURACIÓN BÁSICA
-- =========================

-- Deshabilitar columna visual de folds para interfaz más limpia
vim.opt.foldcolumn = "0"

-- Configuración de foldtext para mostrar primera línea con syntax highlighting
-- En lugar de mostrar "--- 10 lines ---", muestra la primera línea con colores
-- Usamos función simple en lugar de string vacío para evitar problemas de escape
vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"

-- Configuración de niveles de anidamiento y apertura inicial
vim.opt.foldnestmax = 3 -- máximo 3 niveles de folds anidados
vim.opt.foldlevel = 99 -- abrir todos los folds por defecto
vim.opt.foldlevelstart = 99 -- iniciar con todos los folds abiertos al abrir archivo

-- =========================
-- CONFIGURACIÓN INTELIGENTE DE FOLD METHOD
-- =========================

-- Configuración automática: treesitter si disponible, indent como fallback
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
	callback = function()
		-- Verificar si treesitter tiene parser para el filetype actual
		local has_ts_parser = false
		if nixCats("syntax") then
			local success, ts_parsers = pcall(require, "nvim-treesitter.parsers")
			if success and vim.bo.filetype ~= "" then
				has_ts_parser = ts_parsers.has_parser(vim.bo.filetype)
			end
		end

		-- Configurar método apropiado basado en disponibilidad de parser
		if has_ts_parser then
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		else
			vim.opt_local.foldmethod = "indent"
			vim.opt_local.foldexpr = "" -- limpiar foldexpr cuando usamos indent
		end
	end,
	desc = "Configurar método de fold: treesitter si disponible, indent como fallback",
})

-- =========================
-- KEYMAPS DE FOLDING
-- =========================

-- NOTA: Keymaps nativos de Vim que ya están disponibles:
-- zo = [O]pen fold bajo cursor (abrir fold actual)
-- zc = [C]lose fold bajo cursor (cerrar fold actual)
-- za = toggle [A]ll fold bajo cursor (alternar fold actual)
-- zR = [R]educe fold level, open all folds (abrir TODOS los folds)
-- zM = [M]ore fold level, close all folds (cerrar TODOS los folds)
-- zj = saltar al siguiente fold
-- zk = saltar al fold anterior

-- Keymaps adicionales para mejorar flujo de trabajo
local keymap_opts = { noremap = true, silent = true }

-- Space para toggle fold (más intuitivo que 'za')
vim.keymap.set(
	"n",
	"<space>",
	"za",
	vim.tbl_extend("force", keymap_opts, {
		desc = "Toggle fold bajo cursor (abrir/cerrar fold actual)",
	})
)

-- Navegación entre folds más intuitiva con corchetes
vim.keymap.set(
	"n",
	"]z",
	"zj",
	vim.tbl_extend("force", keymap_opts, {
		desc = "Ir al siguiente fold (navegar hacia abajo entre folds)",
	})
)

vim.keymap.set(
	"n",
	"[z",
	"zk",
	vim.tbl_extend("force", keymap_opts, {
		desc = "Ir al fold anterior (navegar hacia arriba entre folds)",
	})
)

-- Focus mode: cerrar todos los folds excepto el actual
vim.keymap.set(
	"n",
	"<leader>zf",
	"zMzvzz",
	vim.tbl_extend("force", keymap_opts, {
		desc = "[F]ocus: cerrar todos los folds excepto el actual y centrar",
	})
)

-- Keymaps con leader para operaciones globales
vim.keymap.set(
	"n",
	"<leader>zo",
	"zR",
	vim.tbl_extend("force", keymap_opts, {
		desc = "[O]pen all folds (abrir todos los folds del archivo)",
	})
)

vim.keymap.set(
	"n",
	"<leader>zc",
	"zM",
	vim.tbl_extend("force", keymap_opts, {
		desc = "[C]lose all folds (cerrar todos los folds del archivo)",
	})
)
