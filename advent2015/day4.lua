local md5 = require "md5"

local key = "bgvyzdsv"

for i = 1, math.maxinteger do
	local sum = md5.sumhexa(key .. tonumber(i))
	
	if sum:match "^000000" then
		print(i, sum)
		break
	end
end