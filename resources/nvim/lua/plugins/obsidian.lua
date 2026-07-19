return {
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = true,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("obsidian").setup({
				disable_frontmatter = true,
				workspaces = {
					{
						name = "personal",
						path = "$OBSIDIAN_VAULT",
					},
				},
				ui = {
					enable = false,
				},
			})
			vim.keymap.set("n", "<leader>so", ":ObsidianOpen<CR>", { desc = "Open the file in Obsidian" })
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
		ft = "markdown",
		event = "VeryLazy",
		opts = function()
			local colors = require("tokyonight.colors").setup()
			vim.api.nvim_set_hl(0, "RMdH1", { fg = colors.red, bg = "" })
			vim.api.nvim_set_hl(0, "RMdH2", { fg = colors.yellow, bg = "" })
			vim.api.nvim_set_hl(0, "RMdH3", { fg = colors.green, bg = "" })
			vim.api.nvim_set_hl(0, "RMdH4", { fg = colors.blue1, bg = "" })
			vim.api.nvim_set_hl(0, "RMdH5", { fg = colors.teal, bg = "" })
			vim.api.nvim_set_hl(0, "RMdH6", { fg = colors.purple, bg = "" })
			-- vim.api.nvim_set_hl(0, 'RMdCodeBlock', { bg = '#434343' })

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.opt_local.lbr = true
				end,
			})

			return {
				heading = {
					icons = { "✱ ", "✲ ", "✤ ", "✣ ", "✸ ", "✳ " },
					backgrounds = {
						"RMdH1",
						"RMdH2",
						"RMdH3",
						"RMdH4",
						"RMdH5",
						"RMdH6",
					},
				},
				latex = {
					enabled = false,
					converter = "latex2text",
					highlight = "RenderMarkdownMath",
					top_pad = 0,
					bottom_pad = 1,
				},
				code = {
					sign = false,
					left_pad = 1,
					-- highlight = 'RMdCodeBlock',
				},
				quote = {
					icon = "┃",
				},
				pipe_table = {
					enabled = true,
					preset = "round",
					style = "full",
				},
			}
		end,
	},
}
