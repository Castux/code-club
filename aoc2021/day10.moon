closing = {"[": "]", "(": ")", "<": ">", "{": "}"}
corrupted_points = {")": 3, "]": 57, "}": 1197, ">": 25137}
incomplete_points = {")": 1, "]": 2, "}": 3, ">": 4}

process = (line) ->
	stack = {}
	for char in line\gmatch "."
		if closing[char]
			table.insert stack, char
		elseif char != closing[table.remove stack]
			return "corrupted", corrupted_points[char]

	score = 0
	while #stack > 0
		score *= 5
		score += incomplete_points[closing[table.remove stack]]
	return "incomplete", score

do
	part1 = 0
	part2 = {}
	for line in io.lines "day10.txt"
		status, score = process line
		switch status
			when "corrupted"
				part1 += score
			when "incomplete"
				table.insert part2, score

	print "Part 1", part1
	table.sort part2
	print "Part 2", part2[#part2 // 2 + 1]
