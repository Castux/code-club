class Map
	new: (data, outside) =>
		@data = data
		@outside = outside
		@num_rows = #data
		@num_cols = #data[1]

	get: (row, col) =>
		if not @data[row] or not @data[row][col]
			@outside
		else
			@data[row][col]

	get_neighbourhood: (row, col) =>
		num = 0
		for r = row - 1, row + 1 do for c = col - 1, col + 1
			num <<= 1
			num |= self\get r, c
		num

	enhance: (algo) =>
		data = for row = -1, @num_rows + 1
			for col = -1, @num_cols + 1
				index = self\get_neighbourhood row, col
				algo[index + 1]
		outside = algo[if @outside == 0 then 1 else #algo]
		Map data, outside

	count_lit: () =>
		assert @outside == 0
		count = 0
		for row in *@data do for value in *row
			count += value
		count

do
	fp = io.open "day20.txt"
	algo = for c in fp\read("l")\gmatch(".")
		c == "#" and 1 or 0
	fp\read "l"

	data = for line in fp\lines "l"
		for c in line\gmatch "."
			if c == "#" then 1 else 0
	map = Map data, 0

	for i = 1,50
		map = map\enhance algo
		print "Part 1", map\count_lit! if i == 2
		print "Part 2", map\count_lit! if i == 50
