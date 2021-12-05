load_data = () ->
	return for line in io.lines "day05.txt"
		x1,y1,x2,y2 = line\match "(%d+),(%d+) %-> (%d+),(%d+)"
		x1: tonumber(x1), y1: tonumber(y1), x2: tonumber(x2), y2: tonumber(y2)

sign = (a,b) -> if a == b then 0 else (b - a) // math.abs(b - a)
interp = (a,b,i) -> a + i * sign(a,b)

iter = (segment) -> with segment
	steps = math.max(math.abs(.x1 - .x2), math.abs(.y1 - .y2))
	return for i = 0, steps do
		x: interp(.x1, .x2, i), y: interp(.y1, .y2, i)

accumulate = (segments, diagonals) ->
	map = {}
	for seg in *segments
		if not diagonals and seg.x1 != seg.x2 and seg.y1 != seg.y2
			continue
		for point in *iter seg
			hash = point.x .. ":" .. point.y
			map[hash] = (map[hash] or 0) + 1
	#[1 for k,v in pairs map when v >= 2]

data = load_data!
print "Part 1", accumulate data
print "Part 2", accumulate(data, true)
