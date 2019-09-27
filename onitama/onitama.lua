-- Utils

local Top = 1
local Bottom = -1

local Student = 1
local Master = 2

local Empty = 0

local samePlayer = function(a,b)
	return a * b > 0
end

local function tableCopy(t)

	if type(t) ~= "table" then
		return t
	end

	local res = {}
	for k,v in pairs(t) do
		res[k] = tableCopy(v)
	end

	return res
end

-- Cards

local Cards =
{
	Tiger = {{-2,0},{1,0}},
	Crab = {{-1,0},{0,-2},{0,2}},
	Monkey = {{-1,-1},{-1,1},{1,-1},{1,1}},
	Crane = {{-1,0},{1,-1},{1,1}},
	Dragon = {{-1,-2},{-1,2},{1,-1},{1,1}},
	Elephant = {{-1,-1},{-1,1},{0,-1},{0,1}},
	Mantis = {{-1,-1},{-1,1},{1,0}},
	Boar = {{-1,0},{0,-1},{0,1}},
	Frog = {{-1,-1},{0,-2},{1,1}},
	Goose = {{-1,-1},{0,-1},{0,1},{1,1}},
	Horse = {{-1,0},{0,-1},{1,0}},
	Eel = {{-1,-1},{0,1},{1,-1}},
	Rabbit = {{-1,1},{0,2},{1,-1}},
	Rooster = {{-1,1},{0,-1},{0,1},{1,-1}},
	Ox = {{-1,0},{0,1},{1,0}},
	Cobra = {{-1,1},{0,-1},{1,1}}
}

-- State definition

local StartState =
{
	topCards = {"Tiger", "Crab"},
	bottomCards = {"Dragon", "Crane"},
	nextCard = "Monkey",
	currentPlayer = Bottom,
	grid =
	{
		{1,1,2,1,1},
		{0,0,0,0,0},
		{0,0,0,0,0},
		{0,0,0,0,0},
		{-1,-1,-2,-1,-1}
	}
}

-- Properties

local hasMaster = function(state,player)
	
	for _,line in ipairs(state.grid) do
		for _,cell in ipairs(line) do
			if cell == Master * player then
				return true
			end
		end
	end
	return false
end

local getWinner = function(state)
	
	if state.grid[1][3] == Bottom * Master then
		return Bottom
		
	elseif state.grid[5][3] == Top * Master then
		return Top
		
	elseif not hasMaster(state,Top) then
		return Bottom
	
	elseif not hasMaster(state,Bottom) then
		return Top
		
	else
		return nil
	end
end

local getPawns = function(state,player) 
	
	local res = {}
	
	for row,line in ipairs(state.grid) do
		for col,cell in ipairs(line) do
			if samePlayer(cell,player) then
				res[#res+1] = {row,col}
			end
		end
	end
	return res
end

local validPosition = function(row,col)
	return row >= 1 and row <= 5 and col >= 1 and col <= 5
end

-- Moves

local validMoves = function(state)
	
	local res = {}
	
	if getWinner(state) then
		return res
	end
	
	local player = state.currentPlayer
	local cards = player == Top and state.topCards or state.bottomCards
	
	for _,card in ipairs(cards) do
		for _,pawn in ipairs(getPawns(state,player)) do
			for _,offset in ipairs(Cards[card]) do
				
				local orow,ocol = offset[1],offset[2]
				if player == Top then
					orow,ocol = -orow,-ocol
				end
				
				local drow,dcol = pawn[1] + orow, pawn[2] + ocol
				if validPosition(drow,dcol) then
					
					local dcell = state.grid[drow][dcol]
					if not samePlayer(player,dcell) then
						res[#res + 1] =
						{
							card = card,
							from = pawn,
							to = {drow,dcol}
						}
					end
				end
			end
		end		
	end
	
	return res
end

local applyMove = function(state, move)
	
	local destPawn = state.grid[move.to[1]][move.to[2]]
	local origPawn = state.grid[move.from[1]][move.from[2]]
	
	-- Move
	
	state.grid[move.to[1]][move.to[2]] = origPawn
	state.grid[move.from[1]][move.from[2]] = Empty
	
	-- Cards

	local cards = state.currentPlayer == Top and state.topCards or state.bottomCards
	if cards[1] == move.card then
		cards[1] = state.nextCard
	else
		cards[2] = state.nextCard
	end
	
	local cardReceived = state.nextCard
	state.nextCard = move.card
	
	-- Player
	
	state.currentPlayer = -state.currentPlayer
	
	-- Return info for reversibility
	
	return destPawn, cardReceived
end

local undoMove = function(state, move, capture, received)
	
	local pawn = state.grid[move.to[1]][move.to[2]]
	
	-- Unmove
	
	state.grid[move.from[1]][move.from[2]] = pawn
	state.grid[move.to[1]][move.to[2]] = capture

	-- Unplayer
	
	state.currentPlayer = -state.currentPlayer
	
	-- Uncard
	
	local cards = state.currentPlayer == Top and state.topCards or state.bottomCards
	
	if cards[1] == received then
		cards[1] = move.card
	else
		cards[2] = move.card
	end
	
	state.nextCard = received
end

-- Debug drawing

local pawnToString =
{
	[1] = "t",
	[2] = "T",
	[-1] = "b",
	[-2] = "B"
}

local gridToString = function(grid)
	local res = ""
	for _,line in ipairs(grid) do
		for _,cell in ipairs(line) do
			res = res .. (pawnToString[cell] or ".")
		end
		res = res .. "\n"
	end
	return res
end

local stateToString = function(state)
	local w = getWinner(state)
	
	return
		table.concat(state.topCards, ",") .. 
		(state.currentPlayer == Top and (",[" .. state.nextCard .. "]") or "") ..
		(w == Top and " WIN" or "") ..
		"\n" ..
		gridToString(state.grid) ..
		table.concat(state.bottomCards, ",") ..
		(state.currentPlayer == Bottom and (",[" .. state.nextCard .. "]") or "") ..
		(w == Bottom and " WIN" or "")
		
end

local moveToString = function(move)
	return move.card .. " " ..
		"(" .. move.from[1] .. "," .. move.from[2] .. ") -> " ..
		"(" .. move.to[1] .. "," .. move.to[2] .. ")"
end


return
{
	Cards = Cards,
	StartState = StartState,
	samePlayer = samePlayer,
	Top = Top,
	Bottom = Bottom,
	Student = Student,
	Master = Master,
	Empty = Empty,
	getWinner = getWinner,
	validMoves = validMoves,
	applyMove = applyMove,
	undoMove = undoMove,
	copyState = tableCopy,
	stateToString = stateToString,
	moveToString = moveToString
}
