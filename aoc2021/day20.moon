import p from require "moon"

class Map
	new: =>
		@data = {}
		@outside = 0
		@min_row = math.maxinteger
		@max_row = math.mininteger
		@min_col = math.maxinteger
		@max_col = math.mininteger

	set: (row, col, v) =>
		if not @data[row] then @data[row] = {}
		@data[row][col] = v
		@min_row = math.min @min_row, row
		@max_row = math.max @max_row, row
		@min_col = math.min @min_col, col
		@max_col = math.max @max_col, col

	get: (row, col) =>
		if row < @min_row or row > @max_row or col < @min_col or col > @max_col
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
		tmp = Map!
		for row = @min_row - 1, @max_row + 1
			for col = @min_col - 1, @max_col + 1
				index = self\get_neighbourhood row, col
				tmp\set row, col, algo[index + 1]
		tmp.outside = algo[@outside == 0 and 1 or #algo]
		tmp

	count_lit: () =>
		assert @outside == 0
		count = 0
		for row = @min_row, @max_row
			for col = @min_col, @max_col
				count += self\get row,col
		count

load_data = () ->
	fp = io.open "day20.txt"
	algo = for c in fp\read("l")\gmatch(".")
		c == "#" and 1 or 0
	fp\read "l"

	map = Map!
	map.data = for line in fp\lines "l"
		for c in line\gmatch "."
			c == "#" and 1 or 0
	map.min_row, map.min_col = 1, 1
	map.max_row, map.max_col = #map.data, #map.data[1]
	algo, map

do
	algo, map = load_data!
	for i = 1,50
		map = map\enhance algo
		print "Part 1", map\count_lit! if i == 2
		print "Part 2", map\count_lit! if i == 50
