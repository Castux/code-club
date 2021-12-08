data = for line in io.lines "day08.txt"
	left = for s in line\gmatch "(%w+)"
		chars = [c for c in s\gmatch "."]
		table.sort chars
		table.concat chars
	right = [table.remove left, 11 for i = 1,4]
	:left, :right

includes = (big, small) ->
	for i = 1, #small
		if not big\match small\sub(i,i) then return false
	return true

unique = {[2]: 1, [3]: 7, [4]: 4, [7]: 8}

solve = (line) ->
	known = {}

	for v in *line.left
		if digit = unique[#v]
			known[digit] = v

	for v in *line.left do if #v == 6
		if includes(v, known[7])
			if includes(v, known[4])
				known[9] = v
			else
				known[0] = v
		else
			known[6] = v

	for v in *line.left do if #v == 5
		if includes(v, known[7])
			known[3] = v
		elseif includes(known[6], v)
			known[5] = v
		else
			known[2] = v

	for k,v in pairs known do known[v] = k
	for i,v in ipairs line.right do table.insert line, known[v]
	line.left, line.right = nil, nil

part1 = 0
part2 = 0

for line in *data
	solve line
	for digit in *line do switch digit
		when 1,4,7,8
			part1 += 1
	part2 += tonumber(table.concat line)

print "Part 1", part1
print "Part 2", part2
