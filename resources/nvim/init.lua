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

require("vim-options")
require("utils.todo_events").setup()
require("lazy").setup("plugins")

local function search_and_open_qf(vimgrep_cmd)
	-- clear quickfix list
	vim.fn.setqflist({})

	-- run vimgrep, pcall catches errors if 0 matches are found
	pcall(vim.cmd, vimgrep_cmd)
	local qf_list = vim.fn.getqflist()

	if #qf_list > 0 then
		vim.cmd("copen")
		print(string.format("Found %d non-ASCII characters!", #qf_list))
	else
		print("Clean! No rogue non-ASCII characters found.")
	end
end

vim.keymap.set("n", "<leader>fm", function()
	if vim.bo.binary then
		print("Skipping: Current file is binary")
		return
	end

	search_and_open_qf("vimgrep /[^\\x00-\\x7FäöüßÄÖÜ]/ %")
end, { desc = "Find non-ASCII in current text buffer" })

vim.keymap.set("n", "<leader>fw", function()
	local text_extensions = "{txt,md,json,html,css,js,ts,py,sh,go,rs,lua,yml,yaml,tex,xml}"

	local cmd = string.format("vimgrep /[^\\x00-\\x7FäöüßÄÖÜ]/ **/*.%s", text_extensions)
	search_and_open_qf(cmd)
end, { desc = "Find non-ASCII in workspace text files" })
