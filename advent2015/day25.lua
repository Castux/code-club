
local function sequence()
	
	local code = 20151125
	local row,col = 1,1
	
	while true do
		
		row = row - 1
		col = col + 1
		
		if row < 1 then
			row = col
			col = 1
		end
		
		code = (code * 252533) % 33554393
		
		if row == 3010 and col == 3019 then
			print(row, col, code)
			break
		end
		
	end
	
	
end

sequence()