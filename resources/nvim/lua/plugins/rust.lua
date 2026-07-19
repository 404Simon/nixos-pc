return {
	"mrcjkb/rustaceanvim",
	version = "^8", -- Recommended
	lazy = false, -- This plugin is already lazy
	init = function()
		vim.g.rustaceanvim = {
			-- LSP configuration
			server = {
				default_settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true, -- This enables 'ssr', 'hydrate', etc.
							loadOutDirsFromCheck = true,
							runBuildScripts = true,
						},
						-- These help with Leptos macro expansion
						procMacro = {
							enable = true,
							ignored = {
								["leptos_macro"] = {
									-- add macros here if they cause performance issues
								},
							},
						},
					},
				},
			},
		}
	end,
}
