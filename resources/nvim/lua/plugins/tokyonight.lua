return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night",
				transparent = true,
				styles = {
					sidebars = "transparent",
					floats = "transparent",
				},
			})

			vim.cmd("colorscheme tokyonight-night")

			-- vim.api.nvim_create_user_command("Day", function()
			-- 	vim.cmd("colorscheme tokyonight-day")
			-- end, {})
			--
			-- vim.api.nvim_create_user_command("Night", function()
			-- 	vim.cmd("colorscheme tokyonight-night")
			-- end, {})
			vim.api.nvim_create_user_command("Day", function()
				require("tokyonight").setup({ style = "day", transparent = false })
				vim.cmd("colorscheme tokyonight-day")
			end, {})
			vim.api.nvim_create_user_command("Night", function()
				require("tokyonight").setup({
					style = "night",
					transparent = true,
					styles = { sidebars = "transparent", floats = "transparent" },
				})
				vim.cmd("colorscheme tokyonight-night")
			end, {})
		end,
	},
}
