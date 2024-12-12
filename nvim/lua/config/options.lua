vim.g.mapleader = " "
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.wo.number = true

if os.getenv("WSL_DISTRO_NAME") ~= nil then
	-- WSL config
	vim.opt.clipboard = "unnamedplus"
else
	-- Linux config
	vim.opt.clipboard = "unnamed"
end
