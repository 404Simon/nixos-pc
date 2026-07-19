return
-- {
-- 	{
-- 		"chomosuke/typst-preview.nvim",
-- 		lazy = false, -- or ft = 'typst'
-- 		version = "1.*",
-- 		opts = {}, -- lazy.nvim will implicitly calls `setup {}`
-- 	},
-- }
{ -- TODO: revert this as soon as I upstreamed native webview
	dir = "/home/simon/dev/typst-preview.nvim",
	name = "typst-preview.nvim",
	ft = "typst",
	config = function()
		require("typst-preview").setup({
			use_native_webview = true,
		})
	end,
}
