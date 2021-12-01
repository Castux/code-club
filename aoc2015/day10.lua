local function iterate(s)
	
	local res = {}
	local i = 1
	while i <= #s do
		
		local head = s:sub(i,i)
		local patt = "^" .. head .. "+"
		local seq = s:match(patt, i)
		
		table.insert(res, tonumber(#seq) .. head)
		i = i + #seq
	end
	
	return table.concat(res)
end

local function test()
	
	assert(iterate "1" == "11")
	assert(iterate "11" == "21")
	assert(iterate "21" == "1211")
	assert(iterate "1211" == "111221")
	assert(iterate "111221" == "312211")
end

test()

local function run()
	
	local s = "3113322113"
	
	for i = 1,50 do
		s = iterate(s)
		
		if i == 40 or i == 50 then
			print(i, #s)
		end
	end
end

run()