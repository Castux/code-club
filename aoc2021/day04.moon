size = 5

load_data = ->
	txt = io.open("day04.txt")\read("a")

	boards = for block in txt\gsub("\n\n", "S")\gmatch("[^S]+")
		[tonumber(num) for num in block\gmatch("%d+")]
	draw = table.remove boards, 1

	for board in *boards
		board.rows = [0 for i = 1, size]
		board.cols = [0 for i = 1, size]

	{:draw, :boards, full: {}}

score_board = (board, number) ->
	sum = 0
	for v in *board
		if v != true then sum += v
	sum * number

handle_board = (board, number) ->
	for i,v in ipairs board
		if v == number
			board[i] = true
			board.rows[(i-1) // size + 1] += 1
			board.cols[(i-1) % size + 1] += 1
			if board.rows[(i-1) // size + 1] == size or board.cols[(i-1) % size + 1] == size
				board.score = score_board(board, number)
			break


mark_next_number = (data) ->
	number = table.remove data.draw, 1
	for i,board in ipairs data.boards
		handle_board board, number
		if board.score
			table.remove(data.boards, i)
			table.insert(data.full, board)

data = load_data!

part1 = () ->
	while true
		mark_next_number(data)
		if #data.full >= 1
			print data.full[1].score
			break

part2 = () ->
	while true
		mark_next_number(data)
		if #data.boards == 0
			print data.full[#data.full].score
			break

part1!
part2!
