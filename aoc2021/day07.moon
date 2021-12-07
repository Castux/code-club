data = [tonumber(n) for n in io.open("day07.txt")\read("a")\gmatch("%d+")]
table.sort data

min1, min2 = math.maxinteger, math.maxinteger
for target = data[1], data[#data]
	cost1, cost2 = 0, 0
	for v in *data
		dist = math.abs(v - target)
		cost1 += dist
		cost2 += dist * (dist + 1) // 2
	min1 = math.min min1, cost1
	min2 = math.min min2, cost2

print "Part 1", min1
print "Part 2", min2
