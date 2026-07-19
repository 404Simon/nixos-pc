-- run with `nvim -l todo_events_spec.lua`

local todo_events = require("utils.todo_events")

local function create_mock_event(overrides)
	local default = {
		title = "Test Event",
		interval_weeks = 1,
		day = 15,
		month = 4,
		start_hour = 10,
		start_min = 15,
		end_hour = 12,
		end_min = 0,
		start_time = "10:15",
		end_time = "12:00",
	}
	for k, v in pairs(overrides or {}) do
		default[k] = v
	end
	return default
end

local pass = 0
local fail = 0

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		pass = pass + 1
		print("  ✓ " .. name)
	else
		fail = fail + 1
		print("  ✗ " .. name .. ": " .. tostring(err))
	end
end

local function describe(name, fn)
	print("\n" .. name)
	fn()
end

local test_cases = {
	parse_interval = {
		{ input = nil, expected = 1, desc = "nil returns 1" },
		{ input = "", expected = 1, desc = "empty string returns 1" },
		{ input = "1", expected = 1, desc = "number string 1" },
		{ input = "2", expected = 2, desc = "number string 2" },
		{ input = "one", expected = 1, desc = "word one" },
		{ input = "two", expected = 2, desc = "word two" },
		{ input = "twelve", expected = 12, desc = "word twelve" },
		{ input = "three", expected = 3, desc = "word three" },
		{ input = "invalid", expected = 1, desc = "invalid word returns 1" },
		{ input = "TEN", expected = 10, desc = "uppercase TEN" },
	},

	parse_event = {
		{
			input = "[Übung every 2 weeks starting 20.04. from 10:15 - 12:00]",
			expected = create_mock_event({
				title = "Übung",
				interval_weeks = 2,
				day = 20,
				month = 4,
			}),
			desc = "recurring with explicit interval",
		},
		{
			input = "[Vorlesung every weeks starting 15.04. from 14:15 - 15:45]",
			expected = create_mock_event({
				title = "Vorlesung",
				interval_weeks = 1,
				day = 15,
				month = 4,
				start_hour = 14,
				start_min = 15,
				end_hour = 15,
				end_min = 45,
				start_time = "14:15",
				end_time = "15:45",
			}),
			desc = "recurring without explicit interval (default 1)",
		},
		{
			input = "[Übung on 20.04. from 10:15 - 12:00]",
			expected = create_mock_event({
				title = "Übung",
				interval_weeks = 0,
				day = 20,
				month = 4,
			}),
			desc = "non-recurring one-time event",
		},
		{
			input = "[Test on 01.01. from 09:00 - 10:00]",
			expected = create_mock_event({
				title = "Test",
				interval_weeks = 0,
				day = 1,
				month = 1,
				start_hour = 9,
				start_min = 0,
				end_hour = 10,
				end_min = 0,
				start_time = "09:00",
				end_time = "10:00",
			}),
			desc = "non-recurring new year event",
		},
		{
			input = "[Seminar every 3 weeks starting 10.10. from 16:00 - 18:00]",
			expected = create_mock_event({
				title = "Seminar",
				interval_weeks = 3,
				day = 10,
				month = 10,
				start_hour = 16,
				start_min = 0,
				end_hour = 18,
				end_min = 0,
				start_time = "16:00",
				end_time = "18:00",
			}),
			desc = "recurring with 3 weeks interval",
		},
		{
			input = "[Invalid event]",
			expected = nil,
			desc = "invalid format returns nil",
		},
		{
			input = "[Event on invalid date]",
			expected = nil,
			desc = "invalid date format returns nil",
		},
		{
			input = "",
			expected = nil,
			desc = "empty string returns nil",
		},
		{
			input = "[Event every week starting 01.01. from 08:00 - 09:00]",
			expected = create_mock_event({
				title = "Event",
				interval_weeks = 1,
				day = 1,
				month = 1,
				start_hour = 8,
				start_min = 0,
				end_hour = 9,
				end_min = 0,
				start_time = "08:00",
				end_time = "09:00",
			}),
			desc = "singular 'weeks' keyword works",
		},
		{
			input = "[CheatSheet Abgabe every week starting 13.04.]",
			expected = {
				title = "CheatSheet Abgabe",
				interval_weeks = 1,
				day = 13,
				month = 4,
				start_hour = nil,
				start_min = nil,
				end_hour = nil,
				end_min = nil,
				start_time = nil,
				end_time = nil,
			},
			desc = "recurring without explicit interval and without time",
		},
		{
			input = "[Seminar every 2 weeks starting 10.10.]",
			expected = {
				title = "Seminar",
				interval_weeks = 2,
				day = 10,
				month = 10,
				start_hour = nil,
				start_min = nil,
				end_hour = nil,
				end_min = nil,
				start_time = nil,
				end_time = nil,
			},
			desc = "recurring with explicit interval and without time",
		},
		{
			input = "[Exam on 31.01.]",
			expected = {
				title = "Exam",
				interval_weeks = 0,
				day = 31,
				month = 1,
				start_hour = nil,
				start_min = nil,
				end_hour = nil,
				end_min = nil,
				start_time = nil,
				end_time = nil,
			},
			desc = "non-recurring without time",
		},
	},

	next_occurrence = {
		{
			input = { event = create_mock_event({ month = 12, day = 25 }), now = os.time() },
			expected_type = "number",
			desc = "future recurring event returns timestamp",
		},
		{
			input = { event = create_mock_event({ interval_weeks = 0, month = 12, day = 25 }), now = os.time() },
			expected_type = "number",
			desc = "non-recurring future returns timestamp",
		},
		{
			input = { event = create_mock_event({ interval_weeks = 2, month = 1, day = 1 }), now = os.time() },
			expected_type = "number",
			desc = "recurring event returns timestamp",
		},
		{
			input = { event = create_mock_event({ interval_weeks = 0, month = 1, day = 1 }), now = os.time() },
			expected = nil,
			desc = "non-recurring past returns nil",
		},
		{
			input = {
				event = create_mock_event({
					month = 12,
					day = 25,
					start_hour = nil,
					start_min = nil,
					end_hour = nil,
					end_min = nil,
					start_time = nil,
					end_time = nil,
				}),
				now = os.time(),
			},
			expected_type = "number",
			desc = "recurring without time returns timestamp",
		},
	},

	format_days_until = {
		{
			input = { timestamp = os.time() + 24 * 60 * 60, now = os.time() },
			expected = "in 1 day",
			desc = "1 day in future",
		},
		{
			input = { timestamp = os.time() + 3 * 24 * 60 * 60, now = os.time() },
			expected = "in 3 days",
			desc = "3 days in future",
		},
		{
			input = { timestamp = os.time(), now = os.time() },
			expected = "today",
			desc = "same day returns today",
		},
		{
			input = { timestamp = os.time() - 24 * 60 * 60, now = os.time() },
			expected = "today",
			desc = "past day returns today",
		},
	},
}

describe("parse_interval", function()
	for _, tc in ipairs(test_cases.parse_interval) do
		test(tc.desc, function()
			local result = todo_events.parse_interval(tc.input)
			assert(result == tc.expected, "expected " .. tostring(tc.expected) .. " got " .. tostring(result))
		end)
	end
end)

describe("parse_event", function()
	for _, tc in ipairs(test_cases.parse_event) do
		test(tc.desc, function()
			local result = todo_events.parse_event(tc.input)
			if tc.expected == nil then
				assert(result == nil, "expected nil got " .. tostring(result))
			else
				assert(result ~= nil, "expected table got nil")
				for k, v in pairs(tc.expected) do
					assert(
						result[k] == v,
						"field " .. k .. ": expected " .. tostring(v) .. " got " .. tostring(result[k])
					)
				end
			end
		end)
	end
end)

describe("next_occurrence", function()
	for _, tc in ipairs(test_cases.next_occurrence) do
		test(tc.desc, function()
			local result = todo_events.next_occurrence(tc.input.event, tc.input.now)
			if tc.expected_type then
				assert(
					type(result) == tc.expected_type,
					"expected type " .. tc.expected_type .. " got " .. type(result)
				)
			else
				assert(result == tc.expected, "expected " .. tostring(tc.expected) .. " got " .. tostring(result))
			end
		end)
	end
end)

describe("format_days_until", function()
	for _, tc in ipairs(test_cases.format_days_until) do
		test(tc.desc, function()
			local result = todo_events.format_days_until(tc.input.timestamp, tc.input.now)
			assert(result == tc.expected, "expected " .. tostring(tc.expected) .. " got " .. tostring(result))
		end)
	end
end)

print(string.format("\n%d passed, %d failed\n", pass, fail))
os.exit(fail > 0 and 1 or 0)
