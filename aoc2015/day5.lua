
local bad_ones = {"ab", "cd", "pq", "xy"}

local function nice(s)

	if not s:match "[aeiou].*[aeiou].*[aeiou]" then
		return false
	end

	if not s:match("(%l)%1") then
		return false
	end

	for _,patt in ipairs(bad_ones) do
		if s:match(patt) then
			return false
		end
	end
	
	return true
end

local function nice_part2(s)
	
	if not s:match "(%l%l).*%1" then
		return false
	end
	
	if not s:match "(%l).%1" then
		return false
	end
	
	return true
end

local function test()
	
	assert(nice "ugknbfddgicrmopn")
	assert(nice "aaa")
	assert(not nice "jchzalrnumimnmhp")
	assert(not nice "haegwjzuvuyypxyu")
	assert(not nice "dvszwmarrgswjxmb")
	
	assert(nice_part2 "qjhvhtzxzqqjkmpb")
	assert(nice_part2 "xxyxx")
	assert(not nice_part2 "uurcxstgmygtbstg")
	assert(not nice_part2 "ieodomkazucvgmuy")
	
	print "Tests successful"
end

test()

local count = 0
local count_part2 = 0

for line in io.lines "day5.txt" do
	if nice(line) then
		count = count + 1
	end
	
	if nice_part2(line) then
		count_part2 = count_part2 + 1
	end
end

print(count, count_part2)