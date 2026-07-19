-- vim_time_jump.lua
-- Supported formats:
-- :M        -> 0:M:00
-- :M:SS     -> 0:M:SS
-- :H:M:SS   -> H:M:SS

local mp = require("mp")
local input = require("mp.input")

local function jump_to_time()
	input.get({
		prompt = ":",
		submit = function(text)
			if not text or text == "" then
				return
			end

			local h, m, s

			local parts = {}
			for part in string.gmatch(text, "[^:]+") do
				table.insert(parts, tonumber(part))
			end

			if #parts == 1 then
				-- :M
				h = 0
				m = parts[1]
				s = 0
			elseif #parts == 2 then
				-- :M:SS
				h = 0
				m = parts[1]
				s = parts[2]
			elseif #parts == 3 then
				-- :H:M:SS
				h = parts[1]
				m = parts[2]
				s = parts[3]
			else
				mp.osd_message("Invalid format")
				return
			end

			if not h or not m or not s then
				mp.osd_message("Invalid number")
				return
			end

			if m >= 60 or s >= 60 then
				mp.osd_message("Minutes and seconds must be < 60")
				return
			end

			local target = h * 3600 + m * 60 + s
			mp.commandv("seek", target, "absolute")
		end,
	})
end

mp.add_key_binding(":", "vim_time_jump", jump_to_time)
