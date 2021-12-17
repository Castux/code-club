target = do
	nums = for num in io.open("day17.txt")\read("a")\gmatch("%-?%d+")
		tonumber num
	xmin: nums[1], xmax: nums[2], ymin: nums[3], ymax: nums[4]

in_target = (x,y) -> with target
	return x >= .xmin and x <= .xmax and y >= .ymin and y <= .ymax
sign = (x) -> if x != 0 then x / math.abs x else 0

shoot = (vx, vy) ->
	x,y = 0,0
	top = y
	while y >= target.ymin
		x += vx
		y += vy
		top = math.max top, y
		vx -= sign vx
		vy -= 1
		if in_target x,y then return true, top
	false

best = 0
count = 0
for vx = -10,300
	for vy = -100,400
		hit, top = shoot vx,vy
		if hit
			best = math.max best, top
			count += 1

print "Part 1", best
print "Part 2", count
