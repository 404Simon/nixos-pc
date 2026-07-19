return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		lazy = false,
		config = function()
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_nvim_lsp.default_capabilities()
			)

			local inlay_hints = {
				enabled = true,
				exclude = {},
			}

			local servers = {
				"tailwindcss",
				"lua_ls",
				"clangd",
				"gopls",
				"jsonls",
				"marksman",
				"phpactor",
				"pyrefly",
				"ruff",
				"stimulus_ls",
				"stylua",
				"pint",
				-- jdtls is configured separately
			}

			local server_settings = {
				lua_ls = {
					settings = {
						Lua = {
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
						},
					},
				},
				pyrefly = {
					on_attach = function(client)
						client.server_capabilities.documentFormattingProvider = false
						client.server_capabilities.documentRangeFormattingProvider = false
					end,
				},
				ruff = {
					on_attach = function(client)
						client.server_capabilities.definitionProvider = false
						client.server_capabilities.referencesProvider = false
						client.server_capabilities.documentSymbolProvider = false
						client.server_capabilities.completionProvider = false
						client.server_capabilities.hoverProvider = false
					end,
				},
			}

			for _, lsp in ipairs(servers) do
				local config = {
					capabilities = capabilities,
				}
				-- Merge server-specific settings if they exist
				if server_settings[lsp] then
					config = vim.tbl_deep_extend("force", config, server_settings[lsp])
				end
				vim.lsp.config(lsp, config)
			end

			require("mason-tool-installer").setup({ ensure_installed = servers })

			-- Enable inlay hints
			if inlay_hints.enabled then
				local snacks_ok, snacks = pcall(require, "snacks")
				if snacks_ok and snacks.util and snacks.util.lsp then
					snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
						if
							vim.api.nvim_buf_is_valid(buffer)
							and vim.bo[buffer].buftype == ""
							and not vim.tbl_contains(inlay_hints.exclude, vim.bo[buffer].filetype)
						then
							vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
						end
					end)
				end
			end

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, {})
			vim.keymap.set("n", "<leader>th", function()
				local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
				vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
				vim.notify("Inlay hints " .. (enabled and "disabled" or "enabled"))
			end, { desc = "Toggle inlay hints" })
		end,
	},
	{
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
			{
				"<leader>tf",
				function()
					if vim.b.disable_autoformat then
						vim.cmd("FormatEnable")
						vim.notify("Enabled autoformat for current buffer")
					else
						vim.cmd("FormatDisable!")
						vim.notify("Disabled autoformat for current buffer")
					end
				end,
				desc = "Toggle autoformat for current buffer",
			},
			{
				"<leader>tF",
				function()
					if vim.g.disable_autoformat then
						vim.cmd("FormatEnable")
						vim.notify("Enabled autoformat globally")
					else
						vim.cmd("FormatDisable")
						vim.notify("Disabled autoformat globally")
					end
				end,
				desc = "Toggle autoformat globally",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				local disable_filetypes = { c = false, cpp = false }
				return {
					timeout_ms = 500,
					lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "gofmt", "goimports" },
				php = { "pint" },
				blade = { "blade-formatter" },
				tex = { "tex-fmt" },
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)

			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})

			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
	},
}
