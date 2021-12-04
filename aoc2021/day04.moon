local size

load_data = ->
	txt = io.open("day04.txt")\read("a")
	boards = for block in txt\gsub("\n\n", "S")\gmatch("[^S]+")
		[tonumber num for num in block\gmatch("%d+")]
	draw = table.remove boards, 1
	size = math.sqrt #boards[1]
	for board in *boards
		board.rows = [0 for i = 1, size]
		board.cols = [0 for i = 1, size]
	{:draw, :boards, full: {}}

score_board = (board, number) ->
	sum = 0
	for v in *board
		if v != true then sum += v
	board.score = sum * number

handle_board = (board, number) ->
	for i,v in ipairs board do if v == number
		board[i] = true
		row, col = (i-1) // size + 1, (i-1) % size + 1
		board.rows[row] += 1
		board.cols[col] += 1
		if board.rows[row] == size or board.cols[col] == size
			score_board board, number
		break

mark_next_number = (data) ->
	number = table.remove data.draw, 1
	for i,board in ipairs data.boards
		handle_board board, number
		if board.score
			table.remove data.boards, i
			table.insert data.full, board

data = load_data!
while #data.boards > 0
	mark_next_number data
print "Part 1", data.full[1].score
print "Part 2", data.full[#data.full].score
