
local function range(x1,y1,x2,y2)

	return coroutine.wrap(function()
			for x = x1,x2 do
				for y = y1,y2 do
					coroutine.yield(x,y)
				end
			end
		end)
end

local function part1()

	local lights = {}

	for x,y in range(0,0,999,999) do
		lights[x] = lights[x] or {}
		lights[x][y] = false
	end


	for line in io.lines "day6.txt" do

		local op,x1,y1,x2,y2 = line:match "^(%D+)(%d+),(%d+)%D*(%d+),(%d+)$"

		for x,y in range(x1,y1,x2,y2) do

			if op == "turn on " then
				lights[x][y] = true

			elseif op == "turn off " then
				lights[x][y] = false

			elseif op == "toggle " then
				lights[x][y] = not lights[x][y]

			else
				error("Bad op:" .. op)
			end
		end
	end

	local count = 0
	for x,y in range(0,0,999,999) do
		if lights[x][y] then
			count = count + 1
		end
	end

	print(count)

end

local function part2()
	
	local lights = {}

	for x,y in range(0,0,999,999) do
		lights[x] = lights[x] or {}
		lights[x][y] = 0
	end
	
	for line in io.lines "day6.txt" do

		local op,x1,y1,x2,y2 = line:match "^(%D+)(%d+),(%d+)%D*(%d+),(%d+)$"

		for x,y in range(x1,y1,x2,y2) do

			if op == "turn on " then
				lights[x][y] = lights[x][y] + 1

			elseif op == "turn off " then
				lights[x][y] = math.max(lights[x][y] - 1, 0)

			elseif op == "toggle " then
				lights[x][y] = lights[x][y] + 2

			else
				error("Bad op:" .. op)
			end
		end
	end
	
	local count = 0
	for x,y in range(0,0,999,999) do
		count = count + lights[x][y]
	end

	print(count)
	
end

part2()