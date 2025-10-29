-- Configuración de auto-session para gestión de sesiones por proyecto
require("lze").load({
	{
		"auto-session",
		enabled = nixCats("sessions") or false,
		event = "VimEnter", -- cargar al iniciar vim
		after = function()
			require("auto-session").setup({
				auto_save_enabled = true, -- guardar sesión automáticamente al salir
				auto_restore_enabled = true, -- restaurar sesión automáticamente al abrir

				-- directorios donde NO crear sesiones (evita sesiones en home, downloads, etc)
				-- IMPORTANTE: incluir "/" para evitar sesiones del directorio raíz
				auto_session_suppress_dirs = {
					"~/",
					"~/Downloads",
					"~/Documents",
					"~/Desktop",
					"/", -- directorio raíz
					"/tmp", -- directorio temporal
					"/var/tmp", -- otro directorio temporal
				},

				-- integración con neotree (cerrar antes de guardar, abrir después de restaurar)
				pre_save_cmds = { "Neotree close" },
				post_restore_cmds = { "Neotree buffers" },

				-- solo mostrar errores en logs (menos verboso)
				log_level = "error",
			})
		end,
	},
})
