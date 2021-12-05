load_data = () ->
	return for line in io.lines "day05.txt"
		x1,y1,x2,y2 = line\match "(%d+),(%d+) %-> (%d+),(%d+)"
		x1: tonumber(x1), y1: tonumber(y1), x2: tonumber(x2), y2: tonumber(y2)

sign = (a,b) ->
	if a <= b then 1 else -1

iter = (segment, diagonals) -> with segment
	if .y1 == .y2
		return for x = .x1, .x2, sign(.x1, .x2)
			{:x, y: .y1}
	elseif .x1 == .x2
		return for y = .y1, .y2, sign(.y1, .y2)
			{x: .x1, :y}
	elseif diagonals
		return for x = .x1, .x2, sign(.x1, .x2)
			{:x, y: .y1 + math.abs(x - .x1) * sign(.y1, .y2)}
	else
		return {}

accumulate = (segments, diagonals) ->
	map = {}
	for seg in *segments
		for point in *(iter seg, diagonals)
			hash = point.x .. ":" .. point.y
			map[hash] = (map[hash] or 0) + 1
	#[1 for k,v in pairs map when v >= 2]

data = load_data!
print "Part 1", accumulate data
print "Part 2", accumulate(data, true)
