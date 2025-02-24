return {
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	opts = {
		-- add options here
		-- or leave it empty to use the default settings
		default = {
			relative_to_current_file = true, ---@type boolean
			dir_path = function()
				return vim.fn.expand("%:t:r") .. "-img"
			end,
		},
	},
	keys = {
		-- suggested keymap
		{ "<leader>si", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
	},
}
