local json = require "json"

local text = io.lines("day12.txt", "a")()

local function part1()
	local sum = 0

	for number in text:gmatch "%-?%d+" do
		sum = sum + tonumber(number)
	end

	print(sum)
end

local function value(node)
	
	-- Number?
	
	local as_num = tonumber(node)
	if as_num then
		return as_num
	end
	
	-- Other string?
	
	if not type(node) == "table" then
		return 0
	end
	
	-- Array?
	
	local sum = 0
	
	if #node > 0 then
		for _,v in ipairs(node) do
			sum = sum + value(v)
		end
		return sum
	end
	
	-- Table?
	
	for k,v in pairs(node) do
		if v == "red" then
			return 0
		end
		sum = sum + value(v)
	end
	
	return sum
end

local function part2()
	
	local data = json.decode(text)
	print(value(data))
	
end

part1()
part2()