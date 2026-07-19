local M = {}

local function replace_umlauts(text)
	local replacements = {
		["ä"] = "ae",
		["ö"] = "oe",
		["ü"] = "ue",
		["ß"] = "ss",
		["Ä"] = "Ae",
		["Ö"] = "Oe",
		["Ü"] = "Ue",
	}
	for umlaut, replacement in pairs(replacements) do
		text = text:gsub(umlaut, replacement)
	end
	return text
end

local function create_note_file(title)
	if not title or title == "" then
		vim.notify("No title provided, exiting...", vim.log.levels.WARN)
		return
	end

	local vault_path = os.getenv("OBSIDIAN_VAULT")
	if not vault_path then
		vim.notify("OBSIDIAN_VAULT environment variable not set", vim.log.levels.ERROR)
		return
	end

	local filename = title:gsub("%s+", "_") .. ".md"
	filename = replace_umlauts(filename)
	local target_path = vault_path .. filename
	local file = io.open(target_path, "r")
	if file then
		file:close()
		vim.notify("Filename already exists: " .. filename, vim.log.levels.WARN)
		-- Retry
		Snacks.input({
			prompt = "File exists! New title: ",
			default = title,
		}, create_note_file)
		return
	end

	local date = os.date("%Y-%m-%d")
	local content = string.format("---\ntitle: %s\ndate: %s\npublish: false\n---\n# %s\n\n\n", title, date, title)

	local file_handle = io.open(target_path, "w")
	if file_handle then
		file_handle:write(content)
		file_handle:close()

		vim.cmd("edit " .. vim.fn.fnameescape(target_path))
		vim.cmd("normal! G")
	else
		vim.notify("Failed to create file: " .. target_path, vim.log.levels.ERROR)
	end
end

function M.create_new_note()
	local vault_path = os.getenv("OBSIDIAN_VAULT")
	if not vault_path then
		vim.notify("OBSIDIAN_VAULT environment variable not set", vim.log.levels.ERROR)
		return
	end

	Snacks.input({
		prompt = "Note title: ",
	}, create_note_file)
end

function M.create_todays_journal_entry()
	local vault_path = os.getenv("OBSIDIAN_VAULT")
	if not vault_path then
		vim.notify("OBSIDIAN_VAULT environment variable not set", vim.log.levels.ERROR)
		return
	end

	local date = os.date("%Y-%m-%d")
	local note_path = vault_path .. "Journal/" .. date .. ".md"

	local file = io.open(note_path, "r")
	if not file then
		local content = string.format("# Daily Note - %s\n\n[[Daily_Notes]]\n\n\n", date)

		local file_handle = io.open(note_path, "w")
		if file_handle then
			file_handle:write(content)
			file_handle:close()
		end
	end
	vim.cmd("edit " .. vim.fn.fnameescape(note_path))
	vim.cmd("normal! G")
end

return M
