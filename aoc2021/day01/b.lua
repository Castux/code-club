local raw = {}
local averaged = {}

local count = 0

for line in io.lines "input.txt" do
	
	local current = tonumber(line)
	table.insert(raw, current)
	
	if #raw >= 3 then
		local average = raw[#raw] + raw[#raw - 1] + raw[#raw - 2]
		table.insert(averaged, average)
	end
	
	if #averaged >= 2 then
		if averaged[#averaged] > averaged[#averaged - 1] then
			count = count + 1
		end
	end
end

print(count)