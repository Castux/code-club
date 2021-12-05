process = (commands, functions) ->
	for v in *commands
		functions[v[1]](tonumber(v[2]))

part1 = (commands) ->
	depth, position = 0, 0
	process commands, {
		forward: (x) -> position += x,
		down: (x) -> depth += x,
		up: (x) -> depth -= x
	}
	depth * position

part2 = (commands) ->
	depth, position, aim = 0, 0, 0
	process commands, {
		forward: (x) ->
			position += x
			depth += aim * x
		down: (x) -> aim += x,
		up: (x) -> aim -= x
	}
	depth * position

commands = [{line\match "(%w+) (%d+)"} for line in io.lines "day02.txt"]

print "Part 1", part1 commands
print "Part 2", part2 commands
