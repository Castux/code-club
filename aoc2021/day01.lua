function count_increases(data)

	local prev = nil
	local count = 0

	for _,current in ipairs(data) do
		
		if prev and current > prev then
			count = count + 1
		end
		
		prev = current
	end
	
	return count
end

function rolling_window(data)

	local result = {}

	for i = 3, #data do
		local sum = data[i] + data[i - 1] + data[i - 2]
		table.insert(result, sum)
	end
	
	return result
end

local data = {}

for line in io.lines "data01.txt" do
	table.insert(data, tonumber(line))
end

print("Part 1", count_increases(data))
print("Part 2", count_increases(rolling_window(data)))