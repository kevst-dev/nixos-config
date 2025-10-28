-- Configuración de Lualine con lze (estilo lazy.nvim)
require('lze').load({
  {
    "lualine.nvim",
    enabled = nixCats('statusline') or false,
    event = "DeferredUIEnter",
    after = function()
      -- 'after' se ejecuta después de cargar el plugin (según documentación de lze)
      require("lualine").setup {
        options = {
          theme = "kanagawa-paper-ink",  -- tema kanagawa paper para lualine
          icons_enabled = true,
          globalstatus = true,
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = { "quickfix", "fugitive" }
      }
    end,
  },
})
print("📊 Lualine configurado correctamente!")
