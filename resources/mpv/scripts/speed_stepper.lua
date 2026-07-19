local STEP = 0.1
local MIN_SPEED = 0.1
local MAX_SPEED = 5.0

local mp = require("mp")

local function clamp(v, min, max)
	if v < min then
		return min
	end
	if v > max then
		return max
	end
	return v
end

local function show_speed(speed)
	mp.osd_message(string.format("Speed: %.1fx", speed), 1.0)
end

local function speed_up()
	local speed = mp.get_property_number("speed", 1.0)
	speed = clamp(speed + STEP, MIN_SPEED, MAX_SPEED)
	mp.set_property_number("speed", speed)
	show_speed(speed)
end

local function speed_down()
	local speed = mp.get_property_number("speed", 1.0)
	speed = clamp(speed - STEP, MIN_SPEED, MAX_SPEED)
	mp.set_property_number("speed", speed)
	show_speed(speed)
end

mp.add_key_binding("d", "speed_up_10pct", speed_up)
mp.add_key_binding("s", "speed_down_10pct", speed_down)
