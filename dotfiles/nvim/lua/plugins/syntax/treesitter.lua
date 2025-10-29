-- ============================================================================
-- CONFIGURACIÓN DIRECTA DE TREESITTER (SIN LZE)
-- ============================================================================
-- Configuración simple y directa de treesitter para evitar problemas con lze

-- Solo configurar si el plugin está disponible (nixCats check + módulo existe)
if nixCats("syntax") then
	-- Verificar que el módulo esté disponible antes de configurar
	local success, ts_configs = pcall(require, "nvim-treesitter.configs")
	if not success then
		print("⚠️ nvim-treesitter.configs no disponible, saltando configuración")
		return
	end

	-- Configuración de treesitter
	ts_configs.setup({
		-- En NixOS, no instalar parsers dinámicamente (solo usar los preinstalados)
		auto_install = false,
		ensure_installed = {},

		highlight = {
			enable = true,
			-- CLAVE: Agregar zsh para vim regex highlighting híbrido
			additional_vim_regex_highlighting = { "org", "zsh" },
		},

		indent = {
			enable = true,
		},

		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@conditional.outer",
					["ic"] = "@conditional.inner",
					["al"] = "@loop.outer",
					["il"] = "@loop.inner",
				},
			},
		},

		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn",
				node_incremental = "grn",
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},
	})

	print("🌳 Treesitter configurado correctamente (modo directo)!")

	-- Debug: verificar configuración
	local config = ts_configs.get_module("highlight")
	if config and config.additional_vim_regex_highlighting then
		print("📝 additional_vim_regex_highlighting:", vim.inspect(config.additional_vim_regex_highlighting))
	end
end
