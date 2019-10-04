local socket = require "socket"
local onitama = require "onitama"

local function playerName(player)
	return player == onitama.Top and "Top" or "Bottom"
end

local columnNames =
{
	a = 1,
	b = 2,
	c = 3,
	d = 4,
	e = 5,
	[1] = "a",
	[2] = "b",
	[3] = "c",
	[4] = "d",
	[5] = "e"
}

local function moveToString(move)
	return move.card .. " " ..
		columnNames[move.from[2]] .. move.from[1] ..
		" " ..
		columnNames[move.to[2]] .. move.to[1]
end

local function startServer(PORT, dumbot)

	local PORT = PORT or 8000
	local server = socket.bind("*", PORT)

	if not server then
		error("Could not start server on port " .. PORT)
	end

	print("Server running on port " .. PORT)

	local clients = {}
	local expectedCount = dumbot and 1 or 2

	while #clients < expectedCount do

		local client = server:accept()
		local ip,port = client:getpeername()
		client:settimeout(0.1)

		table.insert(clients, client)

		local player = #clients == 1 and onitama.Top or onitama.Bottom
		clients[client] = player

		print(playerName(player) .. " player connected: " .. ip)
		client:send("You are " .. playerName(player) .. "\n")
		
	end

	return clients
end

local function printState(game)

	print "======\n"
	print(onitama.stateToString(game))
	print ""

	io.write("Valid moves: ")

	local moves = onitama.validMoves(game)
	for i,move in ipairs(moves) do
		io.write(moveToString(move), i == #moves and "\n" or " / ")
	end
	
	if #moves == 0 then
		print "none"
	end

end

local function startGame(clients)

	math.randomseed(os.time())

	local cardNames = {}
	for k,v in pairs(onitama.Cards) do
		table.insert(cardNames, k)
	end

	local selected = {}
	repeat 
		local i = math.random(#cardNames)
		table.insert(selected, cardNames[i])
		table.remove(cardNames, i)
	until #selected == 5

	local startPlayer = math.random(2)

	local game = onitama.StartState

	game.topCards[1] = selected[1]
	game.topCards[2] = selected[2]
	game.bottomCards[1] = selected[3]
	game.bottomCards[2] = selected[4]
	game.nextCard = selected[5]
	
	game.currentPlayer = startPlayer == 1 and onitama.Top or onitama.Bottom
	
	local msg = "Cards: " .. table.concat(selected, ",") .. "\n" ..
		playerName(game.currentPlayer) .. " starts\n"

	for i,client in ipairs(clients) do
		client:send(msg)
	end
	
	print(playerName(game.currentPlayer) .. " starts")
	printState(game)
	
	return game
end

local function handleInput(game, from, msg, clients)
	
	-- Check current player
	
	if game.currentPlayer ~= from then
		print(playerName(from) .. " player (not their turn) says: " .. msg)
		return
	end
	
	-- Parse input
	
	local card, ocol, orow, dcol, drow = msg:match("^(%w+) (%a)(%d) (%a)(%d)$")
	
	if not (card and ocol and orow and dcol and drow) then
		print(playerName(from) .. " player says: " .. msg)	
		return
	end
	
	-- To numbers
	orow = tonumber(orow)
	drow = tonumber(drow)
	ocol = columnNames[ocol]
	dcol = columnNames[dcol]
	
	-- Move validity
	
	for _,move in ipairs(onitama.validMoves(game)) do
		
		if move.card == card and
			move.from[1] == orow and
			move.from[2] == ocol and
			move.to[1] == drow and
			move.to[2] == dcol then
			
			print(playerName(from) .. " player plays " .. msg)
			
			onitama.applyMove(game, move)
			printState(game)
			
			for _,client in ipairs(clients) do
				client:send(msg .. "\n")
			end
			
			if onitama.getWinner(game) then
				return "abort"
			end
			
			return "played"
		end
	end
	
	print(playerName(from) .. " player submitted an invalid move: " .. msg)
	return "abort"
end

local function playDumb(game, clients)
	
	local moves = onitama.validMoves(game)
	local index = math.random(#moves)
	local move = moves[index]
	
	local msg = moveToString(move)
	
	print("dumbot plays " .. msg)
	
	onitama.applyMove(game, move)
	printState(game)
	
	for _,client in ipairs(clients) do
		client:send(msg .. "\n")
	end
	
end

local function run(game, clients, timeout, dumbot)

	if dumbot and (clients[clients[1]] ~= game.currentPlayer) then
		playDumb(game, clients)
	end

	local turnStart = os.time()

	while true do
		
		if os.time() - turnStart > timeout then
			print(playerName(game.currentPlayer) .. " took too long to play")
			return
		end

		for i,client in ipairs(clients) do

			local msg, err = client:receive("*l")

			if err == "closed" then

				print(playerName(clients[client]) .. " player dropped")
				return

			elseif err == "timeout" then

			else
				local status = handleInput(game, clients[client], msg, clients)
				
				if status == "abort" then
					return
				end
				
				if status == "played" then
					
					if dumbot then
						playDumb(game, clients)
					end
					
					turnStart = os.time()
				end
			end

		end

	end

end

function main(args)

	local timeout, ip, dumbot

	if not args[1] or not args[2] then
		print("Usage: lua judge.lua <port> <timeout> [dumbot]")
		print("Using defaults: port 8000, 15 seconds timeout")
		
		port = 8000
		timeout = 15
	else
		port = tonumber(args[1])
		timeout = tonumber(args[2])
		dumbot = args[3] == "dumbot"
	end
	
	if dumbot then
		math.randomseed(os.time())
	end
	
	print("Timeout set to " .. timeout .. " seconds")
	
	local clients = startServer(port, dumbot)
	local game = startGame(clients)
	run(game, clients, timeout, dumbot)
end

main({...})