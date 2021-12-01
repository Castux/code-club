local prev = nil
local count = 0

for line in io.lines "input.txt" do
	
	local current = tonumber(line)
	
	if prev and current > prev then
		count = count + 1
	end
	
	prev = current
end

print(count)