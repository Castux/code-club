map = for line in io.lines "day09.txt"
		for c in line\gmatch "."
			{height: tonumber(c), from: {}, low: true}

get = (row, col) ->
	if row >= 1 and row <= #map and col >= 1 and col <= #map[row]
		map[row][col]

iter_map = () ->
	coroutine.wrap () ->
		for row = 1,#map do for col = 1,#map[row]
			coroutine.yield get(row, col), row, col

neighbours = (row, col) -> {
	{row + 1, col},
	{row - 1, col},
	{row, col + 1},
	{row, col - 1}
}

low_points = do
	for cell, row, col in iter_map()
		if cell.height == 9
			cell.low = false
			continue

		for {r2,c2} in *neighbours(row,col)
			neighbour = get(r2, c2)
			if neighbour and neighbour.height < cell.height
				cell.low = false
				table.insert neighbour.from, cell
				break

	[cell for cell in iter_map() when cell.low]

basin_size = (cell) ->
	if cell.basin_size then return cell.basin_size
	sum = 1
	for c2 in *cell.from do sum += basin_size c2
	cell.basin_size = sum
	sum

do
	part1 = 0
	for cell in *low_points do part1 += cell.height + 1
	print "Part 1", part1

	part2 = 1
	table.sort low_points, (a,b) -> basin_size(a) > basin_size(b)
	for i = 1,3 do part2 *= basin_size low_points[i]
	print "Part 2", part2
