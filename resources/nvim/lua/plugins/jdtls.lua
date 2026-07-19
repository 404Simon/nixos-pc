return {
	"mfussenegger/nvim-jdtls",
	dependencies = {
		"williamboman/mason.nvim",
	},
	ft = "java",
	config = function()
		local jdtls = require("jdtls")

		local home = os.getenv("HOME")
		local mason_path = vim.fn.stdpath("data") .. "/mason/"
		local jdtls_dir = mason_path .. "packages/jdtls"

		local config_dir = jdtls_dir .. "/config_linux"

		local launcher_jar = vim.fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
		if launcher_jar == "" then
			vim.notify("jdtls launcher jar not found", vim.log.levels.ERROR)
			return
		end

		local root_markers = { "gradlew", ".git", "mvnw", "pom.xml", "build.gradle", "settings.gradle" }
		local root_dir = require("jdtls.setup").find_root(root_markers)
		if root_dir == "" or root_dir == nil then
			root_dir = vim.fn.getcwd()
		end

		local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
		local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name
		vim.fn.mkdir(workspace_dir, "p")

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
		if cmp_ok then
			capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
		end

		local extendedClientCapabilities = jdtls.extendedClientCapabilities
		extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

		local lombok_jar = jdtls_dir .. "/lombok.jar"

		local config = {
			cmd = {
				"java",
				"-Declipse.application=org.eclipse.jdt.ls.core.id1",
				"-Dosgi.bundles.defaultStartLevel=4",
				"-Declipse.product=org.eclipse.jdt.ls.core.product",
				"-Dlog.protocol=true",
				"-Dlog.level=ALL",
				"-Xmx1g",
				"--add-modules=ALL-SYSTEM",
				"--add-opens",
				"java.base/java.util=ALL-UNNAMED",
				"--add-opens",
				"java.base/java.lang=ALL-UNNAMED",
				"-javaagent:" .. lombok_jar,
				"-Xbootclasspath/a:" .. lombok_jar,
				"-jar",
				launcher_jar,
				"-configuration",
				config_dir,
				"-data",
				workspace_dir,
			},
			root_dir = root_dir,
			capabilities = capabilities,
			settings = {
				java = {
					eclipse = {
						downloadSources = true,
					},
					configuration = {
						updateBuildConfiguration = "interactive",
					},
					maven = {
						downloadSources = true,
					},
					implementationsCodeLens = {
						enabled = true,
					},
					referencesCodeLens = {
						enabled = true,
					},
					references = {
						includeDecompiledSources = true,
					},
					inlayHints = {
						parameterNames = {
							enabled = "all",
						},
					},
					contentProvider = {
						preferred = "fernflower",
					},
				},
			},
			init_options = {
				extendedClientCapabilities = extendedClientCapabilities,
			},
		}

		jdtls.start_or_attach(config)
	end,
}
