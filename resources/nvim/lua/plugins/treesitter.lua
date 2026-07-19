-- OBACHT: had to install treesitter-cli with `cargo install tree-sitter-cli`
return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			ts.setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			ts.install({
				"bash",
				"html",
				"css",
				"json",
				"lua",
				"php",
				"rust",
				"python",
				"java",
				"markdown",
				"typst",
				"latex",
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function(args)
					local buftype = vim.bo[args.buf].buftype
					local filetype = vim.bo[args.buf].filetype

					-- skip special buffers and filetypes without parsers
					if buftype ~= "" then
						return
					end

					-- skip snacks startpage
					if filetype:match("^snacks_") then
						return
					end

					-- only start if a parser exists
					local lang = vim.treesitter.language.get_lang(filetype)
					if lang then
						local ok = pcall(vim.treesitter.start, args.buf, lang)
						if not ok then
							-- parser not available, silently skip
							return
						end
					end
				end,
			})
		end,
	},
}
