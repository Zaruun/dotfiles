vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

vim.keymap.set("n", "<leader>nh", ":nohlsearch<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set("n", "<Leader>dw", [[:normal! viw"_d<CR>]])

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- split windows
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- IMAGES

-- PASTE

vim.keymap.set({ "n", "v", "i" }, "<leader>ip", function()
	-- Call the paste_image function from the Lua API
	-- Using the plugin's Lua API (require("img-clip").paste_image()) instead of the
	-- PasteImage command because the Lua API returns a boolean value indicating
	-- whether an image was pasted successfully or not.
	-- The PasteImage command does not
	-- https://github.com/HakonHarnes/img-clip.nvim/blob/main/README.md#api
	local pasted_image = require("img-clip").paste_image()
	if pasted_image then
		-- "Update" saves only if the buffer has been modified since the last save
		vim.cmd("update")
		print("Image pasted and file saved")
		-- Only if updated I'll refresh the images by clearing them first
		-- I'm using [[ ]] to escape the special characters in a command
		-- vim.cmd([[lua require("image").clear()]])
		-- Reloads the file to reflect the changes
		vim.cmd("edit!")
		-- Switch back to command mode or normal mode
		vim.cmd("stopinsert")
	else
		print("No image pasted. File not updated.")
	end
end, { desc = "Paste image from system clipboard" })

-- DELETE
vim.keymap.set("n", "<leader>id", function()
	local function get_image_path()
		-- Get the current line
		local line = vim.api.nvim_get_current_line()
		-- Pattern to match image path in Markdown
		local image_pattern = "%[.-%]%((.-)%)"
		-- Extract relative image path
		local _, _, image_path = string.find(line, image_pattern)

		return image_path
	end
	-- Get the image path
	local image_path = get_image_path()
	if image_path then
		-- Check if the image path starts with "http" or "https"
		if string.sub(image_path, 1, 4) == "http" then
			vim.api.nvim_echo({
				{ "URL image cannot be deleted from disk.", "WarningMsg" },
			}, false, {})
		else
			-- Construct absolute image path
			local current_file_path = vim.fn.expand("%:p:h")
			local absolute_image_path = current_file_path .. "/" .. image_path
			-- Check if trash utility is installed
			-- if vim.fn.executable("trash") == 0 then
			-- 	vim.api.nvim_echo({
			-- 		{ "- Trash utility not installed. Make sure to install it first\n", "ErrorMsg" },
			-- 		{ "- In macOS run `brew install trash`\n", nil },
			-- 	}, false, {})
			-- 	return
			-- end
			-- Prompt for confirmation before deleting the image
			vim.ui.input({
				prompt = "Delete image file? (y/n) ",
			}, function(input)
				if input == "y" or input == "Y" then
					-- Delete the image file using trash app
					local success, _ = pcall(function()
						vim.fn.system({ "rm", vim.fn.fnameescape(absolute_image_path) })
					end)
					if success then
						vim.api.nvim_echo({
							{ "Image file deleted from disk:\n", "Normal" },
							{ absolute_image_path, "Normal" },
						}, false, {})
						-- I'll refresh the images, but will clear them first
						-- I'm using [[ ]] to escape the special characters in a command
						-- vim.cmd([[lua require("image").clear()]])
						-- Reloads the file to reflect the changes
						vim.cmd("edit!")
					else
						vim.api.nvim_echo({
							{ "Failed to delete image file:\n", "ErrorMsg" },
							{ absolute_image_path, "ErrorMsg" },
						}, false, {})
					end
				else
					vim.api.nvim_echo({
						{ "Image deletion canceled.", "Normal" },
					}, false, {})
				end
			end)
		end
	else
		vim.api.nvim_echo({
			{ "No image found under the cursor", "WarningMsg" },
		}, false, {})
	end
end, { desc = "Delete image file under cursor" })
