---
--- todo_events.lua - Neovim plugin for displaying calendar events in TODO.md
---
--- Usage:
--- Write events in ~/Vorlesungen/TODO.md using these formats:
---
---   Recurring: [Title every X weeks starting DD.MM. from HH:MM - HH:MM]
---              [Title every X weeks starting DD.MM.]
---              [Title every weeks starting DD.MM. from HH:MM - HH:MM]
---              [Title every weeks starting DD.MM.]
---   Non-recurring: [Title on DD.MM. from HH:MM - HH:MM]
---                  [Title on DD.MM.]
---
--- Examples:
---   [Übung every 2 weeks starting 20.04. from 10:15 - 12:00]
---   [Vorlesung every weeks starting 15.04. from 14:15 - 15:45]
---   [Übung on 20.04. from 10:15 - 12:00]
---   [Abgabe every week starting 13.04.]
---
--- The plugin displays upcoming events as virtual text overlay showing
--- the event title, days until, date, and time range.
---

local M = {}

local target_file = vim.fs.normalize(vim.fn.expand("~/Vorlesungen/TODO.md"))
local augroup = vim.api.nvim_create_augroup("todo-events", { clear = true })
local namespace = vim.api.nvim_create_namespace("todo-events-virtual")

local function set_highlight()
	vim.api.nvim_set_hl(0, "TodoEventsVirtual", {
		fg = "#89b4fa",
		bg = "#313244",
		sp = "#89b4fa",
		default = true,
	})
end

local number_words = {
	one = 1,
	two = 2,
	three = 3,
	four = 4,
	five = 5,
	six = 6,
	seven = 7,
	eight = 8,
	nine = 9,
	ten = 10,
	eleven = 11,
	twelve = 12,
}

function M.parse_interval(raw)
	if not raw or raw == "" then
		return 1
	end

	local value = tonumber(raw)
	if value then
		return value
	end

	return number_words[string.lower(raw)] or 1
end

function M.parse_event(line)
	local title, raw_interval, day, month, start_time, end_time = line:match(
		"^%[(.-)%s+every%s+([%w%-]+)%s+weeks?%s+starting%s+(%d%d)%.(%d%d)%.%s+from%s+(%d%d:%d%d)%s*%-%s*(%d%d:%d%d)%]$"
	)

	if not title then
		title, day, month, start_time, end_time = line:match(
			"^%[(.-)%s+every%s+weeks?%s+starting%s+(%d%d)%.(%d%d)%.%s+from%s+(%d%d:%d%d)%s*%-%s*(%d%d:%d%d)%]$"
		)
		raw_interval = "1"
	end

	if not title then
		title, raw_interval, day, month =
			line:match("^%[(.-)%s+every%s+([%w%-]+)%s+weeks?%s+starting%s+(%d%d)%.(%d%d)%.%s*%]$")
	end

	if not title then
		title, day, month = line:match("^%[(.-)%s+every%s+weeks?%s+starting%s+(%d%d)%.(%d%d)%.%s*%]$")
		raw_interval = "1"
	end

	if not title then
		title, day, month, start_time, end_time =
			line:match("^%[(.-)%s+on%s+(%d%d)%.(%d%d)%.%s+from%s+(%d%d:%d%d)%s*%-%s*(%d%d:%d%d)%]$")
		raw_interval = "0"
	end

	if not title then
		title, day, month = line:match("^%[(.-)%s+on%s+(%d%d)%.(%d%d)%.%s*%]$")
		raw_interval = "0"
	end

	if not title then
		return nil
	end

	local start_hour, start_min, end_hour, end_min
	if start_time and end_time then
		start_hour, start_min = start_time:match("^(%d%d):(%d%d)$")
		end_hour, end_min = end_time:match("^(%d%d):(%d%d)$")
	end

	return {
		title = vim.trim(title),
		interval_weeks = M.parse_interval(raw_interval),
		day = tonumber(day),
		month = tonumber(month),
		start_hour = start_hour and tonumber(start_hour) or nil,
		start_min = start_min and tonumber(start_min) or nil,
		end_hour = end_hour and tonumber(end_hour) or nil,
		end_min = end_min and tonumber(end_min) or nil,
		start_time = start_time,
		end_time = end_time,
	}
end

function M.next_occurrence(event, now)
	local year = tonumber(os.date("%Y", now))
	local first = os.time({
		year = year,
		month = event.month,
		day = event.day,
		hour = event.start_hour or 0,
		min = event.start_min or 0,
		sec = 0,
	})

	if not first then
		return nil
	end

	if event.interval_weeks == 0 then
		if now <= first then
			return first
		end
		return nil
	end

	local step = event.interval_weeks * 7 * 24 * 60 * 60
	if now <= first then
		return first
	end

	local elapsed = now - first
	local cycles = math.floor(elapsed / step) + 1
	return first + (cycles * step)
end

function M.format_days_until(timestamp, now)
	local start_of_today = os.time({
		year = tonumber(os.date("%Y", now)),
		month = tonumber(os.date("%m", now)),
		day = tonumber(os.date("%d", now)),
		hour = 0,
		min = 0,
		sec = 0,
	})

	local start_of_event_day = os.time({
		year = tonumber(os.date("%Y", timestamp)),
		month = tonumber(os.date("%m", timestamp)),
		day = tonumber(os.date("%d", timestamp)),
		hour = 0,
		min = 0,
		sec = 0,
	})

	local days = math.floor((start_of_event_day - start_of_today) / (24 * 60 * 60))
	if days <= 0 then
		return "today"
	end

	if days == 1 then
		return "in 1 day"
	end

	return string.format("in %d days", days)
end

local function compute_single_event_text(event, now)
	local occurrence = M.next_occurrence(event, now)
	if not occurrence then
		return nil
	end

	local next_date = os.date("%d.%m.", occurrence)
	local days_until = M.format_days_until(occurrence, now)
	local icon = event.interval_weeks > 0 and "󰺎" or "󰃮"

	if event.start_time and event.end_time then
		return string.format(
			" %s %s %s (%s %s - %s) ",
			icon,
			event.title,
			days_until,
			next_date,
			event.start_time,
			event.end_time
		)
	end

	return string.format(" %s %s %s (%s) ", icon, event.title, days_until, next_date)
end

local function is_normal_mode()
	local mode = vim.api.nvim_get_mode().mode
	return mode:sub(1, 1) == "n"
end

local function update_display(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

	if vim.bo[bufnr].buftype ~= "" then
		return
	end

	local file = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
	if file ~= target_file then
		return
	end

	if not is_normal_mode() then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local now = os.time()

	for index, line in ipairs(lines) do
		local event = M.parse_event(vim.trim(line))
		if event then
			local text = compute_single_event_text(event, now)
			if text then
				local pad = math.max(vim.fn.strchars(line) - vim.fn.strchars(text), 0)
				vim.api.nvim_buf_set_extmark(bufnr, namespace, index - 1, 0, {
					virt_text = { { text, "TodoEventsVirtual" }, { string.rep(" ", pad), "" } },
					virt_text_pos = "overlay",
				})
			end
		end
	end
end

function M.setup()
	set_highlight()

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "TextChangedI", "ModeChanged" }, {
		group = augroup,
		pattern = "*",
		callback = function(args)
			update_display(args.buf or vim.api.nvim_get_current_buf())
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = augroup,
		callback = set_highlight,
	})

	vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
		group = augroup,
		pattern = "*",
		callback = function(args)
			vim.api.nvim_buf_clear_namespace(args.buf, namespace, 0, -1)
		end,
	})
end

return M
