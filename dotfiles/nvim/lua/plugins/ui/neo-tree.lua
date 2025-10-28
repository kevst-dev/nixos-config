-- Configuración de Neo-tree con lze (estilo lazy.nvim)
require("lze").load({
	{
		"neo-tree.nvim",
		enabled = nixCats("neotree") or false,
		cmd = "Neotree",
		keys = {
			{ "<leader>T", ":Neotree toggle<cr>" },
			{ "<leader>t", ":Neotree <cr>" },
		},
		after = function()
			-- 'after' se ejecuta después de cargar el plugin (según documentación de lze)
			require("neo-tree").setup({
				close_if_last_window = true,
				window = {
					width = 30,
				},
				filesystem = {
					follow_current_file = {
						enabled = true,
					},
					use_libuv_file_watcher = true,
				},
			})
		end,
	},
})
print("🗄️ Neo-tree configurado correctamente!")
