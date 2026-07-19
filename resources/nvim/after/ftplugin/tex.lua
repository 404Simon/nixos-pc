vim.keymap.set("n", "<leader>p", function()
	local dir = vim.fn.expand("%:p:h")
	local makefiles = {
		dir .. "/Makefile",
		dir .. "/makefile",
		dir .. "/../Makefile",
		dir .. "/../makefile",
	}
	for _, mf in ipairs(makefiles) do
		if vim.loop.fs_stat(mf) then
			local mf_dir = vim.fn.fnamemodify(mf, ":h")
			vim.system({ "make" }, { cwd = mf_dir }, function(obj)
				if obj.code ~= 0 then
					vim.schedule(function()
						vim.notify("make failed: " .. obj.stderr, vim.log.levels.ERROR)
					end)
				end
			end)
			return
		end
	end
	vim.notify("No Makefile found in " .. dir .. " or parent directory", vim.log.levels.WARN)
end, { buffer = 0, desc = "Run make (compile LaTeX)" })
