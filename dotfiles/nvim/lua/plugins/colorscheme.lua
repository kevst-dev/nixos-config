-- Configuración del colorscheme Catppuccin
require("catppuccin").setup({
  flavour = "frappe",
  styles = {
    comments = { "italic" },
    conditionals = { "italic" },
    keywords = { "italic" },
  },
})

vim.cmd.colorscheme "catppuccin-frappe"

print("🎨 Catppuccin configurado correctamente!")