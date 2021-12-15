map = {}
set = (row, col, v) -> map[row .. ":" .. col] = v
get = (row, col) -> map[row .. ":" .. col]

size = 0

load_map = () ->
	row = 1
	for line in io.lines "day15.txt"
		size = #line
		col = 1
		for c in line\gmatch "."
			set row, col, { risk: tonumber(c), :row, :col }
			col += 1
		row += 1

expand_map = () ->
	new_cells = {}
	for _,cell in pairs map
		for dr = 0,4 do for dc = 0,4
			if dr == 0 and dc == 0 then continue
			new =
				row: cell.row + dr * size,
				col: cell.col + dc * size
				risk: cell.risk + dr + dc
			if new.risk > 9 then new.risk -= 9
			table.insert new_cells, new
	for n in *new_cells
		set n.row, n.col, n
	size *= 5

compute_neighbours = () ->
	for _,cell in pairs map
		r, c = cell.row, cell.col
		coords = {{r+1, c}, {r-1, c}, {r, c+1}, {r, c-1}}
		cell.neighbours = [get row, col for {row, col} in *coords when get row, col]

compute_min_costs = () ->
	start = get 1,1
	start.min_cost = 0
	queue = {start}
	next_index = 1

	while next_index <= #queue
		cell = queue[next_index]
		next_index += 1
		for n in *cell.neighbours
			new_cost = cell.min_cost + n.risk
			if not n.min_cost or new_cost < n.min_cost
				n.min_cost = new_cost
				table.insert queue, n

load_map!
expand_map!
compute_neighbours!
compute_min_costs!
print "Part 1", (get size // 5, size // 5).min_cost
print "Part 2", (get size, size).min_cost
