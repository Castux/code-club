local PART2 = true

local pos = {{x = 0, y = 0}, {x = 0, y = 0}}
local houses = {["0:0"] = true}

local who = 1
for dir in io.lines("day3.txt", 1) do
	
	if dir == ">" then
		pos[who].x = pos[who].x + 1
	elseif dir == "<" then
		pos[who].x = pos[who].x - 1
	elseif dir == "^" then
		pos[who].y = pos[who].y - 1
	elseif dir == "v" then
		pos[who].y = pos[who].y + 1
	end
	
	local key = pos[who].x .. ":" .. pos[who].y
	houses[key] = true
	
	if PART2 then
		who = (who % 2) + 1
	end
end

local count = 0

for k,v in pairs(houses) do
	count = count + 1
end

print(count)