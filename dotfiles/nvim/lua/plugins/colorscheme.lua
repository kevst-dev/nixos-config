-- Configuración del colorscheme Catppuccin
-- NO usar lze para colorschemes: van en startupPlugins y configuración directa
-- (según template oficial de nixCats)
require("catppuccin").setup({
  flavour = "frappe",
  styles = {
    comments = { "italic" },
    conditionals = { "italic" },
    keywords = { "italic" },
  },
})

vim.cmd.colorscheme("catppuccin-frappe")

print("🎨 Catppuccin configurado correctamente!")