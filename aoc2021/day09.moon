map = {}
set = (row, col, v) -> map[row .. ":" .. col] = v
get = (row, col) -> map[row .. ":" .. col]

do
	row = 1
	for line in io.lines "day09.txt"
		col = 1
		for c in line\gmatch "."
			set row, col, { height: tonumber(c), :row, :col }
			col += 1
		row += 1

neighbours = (cell) ->
	r, c = cell.row, cell.col
	[get row, col for {row, col} in *{{r+1, c}, {r-1, c}, {r, c+1}, {r, c-1}} when get row, col]

is_low = (cell) ->
	for neighbour in *neighbours cell
		if neighbour.height <= cell.height
			return false
	true

low_points = [cell for _,cell in pairs map when is_low cell]

basin_size = (cell) ->
	if cell.height == 9 or cell.counted then return 0
	cell.counted = true
	size = 1
	for neighbour in *neighbours cell
		size += basin_size neighbour
	size

do
	part1 = 0
	for cell in *low_points do part1 += cell.height + 1
	print "Part 1", part1

	sizes = [basin_size cell for cell in *low_points]
	table.sort sizes, (a, b) -> a > b
	print "Part 2", sizes[1] * sizes[2] * sizes[3]
