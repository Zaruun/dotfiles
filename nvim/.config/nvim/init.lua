local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
require("config.keymaps")
-- Konfiguracja Lazy.nvim
require("lazy").setup({
    spec = {
        { import = "plugins" },
        { import = "plugins.lsp" },
        
        -- Dynamiczne wczytywanie plików z katalogu lang
        -- Każdy z tych plików będzie używać funkcji globalnych z lsp.lua
        -- do rejestracji narzędzi, LSP, formaterów i linterów
    },
    defaults = {
        lazy = false,
        version = false,
    },
    install = { colorscheme = { "github_dark", "habamax" } },
    checker = { enabled = true },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})require("config.autocmds")
