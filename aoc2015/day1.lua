local res = 0
local first_basement

local pos = 1
for char in io.lines("day1.txt", 1) do
	if char == "(" then
		res = res + 1
	elseif char == ")" then
		res = res - 1
	end
	
	if res == -1 and not first_basement then
		first_basement = pos
	end

	pos = pos + 1
end


print(res, first_basement)
