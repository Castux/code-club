map = {}
set = (row, col, v) -> map[row .. ":" .. col] = v
get = (row, col) -> map[row .. ":" .. col]

do
	row = 1
	for line in io.lines "day11.txt"
		col = 1
		for c in line\gmatch "."
			set row, col, { level: tonumber(c), :row, :col }
			col += 1
		row += 1

neighbours = (cell) ->
	r, c = cell.row, cell.col
	[get row,col for row = r-1,r+1 for col = c-1,c+1 when not (row == r and col == c) and get row,col]

flashes = 0
step = () ->
	flashed = {}

	for k,cell in pairs map
		cell.level += 1

	iter = () ->
		any_flashed = false
		for k,cell in pairs map
			if cell.level > 9 and not flashed[cell]
				flashed[cell] = true
				any_flashed = true
				flashes += 1
				for neighbour in *neighbours cell
					neighbour.level += 1
		any_flashed

	while true
		any_flashed = iter!
		if not any_flashed then break

	for k,cell in pairs map
		if cell.level > 9
			cell.level = 0

all_flashed = () ->
	for k,cell in pairs map
		if cell.level != 0 then return false
	true

for i = 1,math.maxinteger
	step!
	if i == 100
		print "Part 1", flashes
	if all_flashed!
		print "Part 2", i
		break
