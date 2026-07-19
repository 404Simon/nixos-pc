vim.keymap.set("n", "<leader>p", function()
	local filename = vim.fn.expand("%:p")
	vim.system({ "apostrophe", filename }, { detach = true })
end, { buffer = 0, desc = "Open file with apostrophe" })
