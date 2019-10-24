local a_byte = string.byte "a"
local z_byte = string.byte "z"


local function str_to_arr(s)
	return table.pack(s:byte(1,#s))
end

local function arr_to_str(arr)
	return string.char(table.unpack(arr))	
end

local function increment(s, arr)
	
	local arr = arr or str_to_arr(s)
	
	local i = #arr
	while i >= 1 do
			
		arr[i] = arr[i] + 1
		if arr[i] > z_byte then
			arr[i] = a_byte
			i = i - 1
		else
			break
		end
		
	end
	
	return arr_to_str(arr), arr
end

local function valid(str, arr)
	
	local arr = arr or str_to_arr(str)
	
	if str:match "[iol]" then
		return false
	end
	
	local p1,p2 = str:match "(.)%1.*(.)%2"
	if not (p1 and p2) or (p1 == p2) then
		return false
	end
	
	for i = 1,#arr-2 do
		
		if arr[i] + 1 == arr[i+1] and arr[i] + 2 == arr[i+2] then
			return true
		end
		
	end
	
	return false
end

local function test()
	
	assert(not valid "hijklmmn")
	assert(not valid "abbceffg")
	assert(not valid "abbcegjk")
	assert(valid "abcdffaa")
	assert(valid "ghjaabcc")
	
	assert(increment "aa" == "ab")
	assert(increment "az" == "ba")
	assert(increment "xz" == "ya")
	
end

test()

local function find_next(s)
	
	local arr = str_to_arr(s)
	
	repeat
		s,arr = increment(s,arr)
	until valid(s,arr)
	
	return s
end

local res = find_next "vzbxkghb"
print(res)
res = find_next(res)
print(res)