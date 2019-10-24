local function range(x1,y1,x2,y2)

	return coroutine.wrap(function()
			for x = x1,x2 do
				for y = y1,y2 do
					coroutine.yield(x,y)
				end
			end
		end)
end

local function load_data()
	
	local grid = {}
	
	for line in io.lines "day18.txt" do
		
		local l = {}
		for i = 1,#line do
			l[i] = line:sub(i,i) == "#"
		end
		
		table.insert(grid, l)
	end
	
	local flat = {}
	
	for x,y in range(1,1,100,100) do
		flat[x .. ":" .. y] = grid[x][y]
	end
	
	return flat
end

local offsets =
{
	{-1,-1},
	{-1,0},
	{-1,1},
	{0,-1},
	{0,1},
	{1,-1},
	{1,0},
	{1,1},
}

local function iterate(grid, part_2)
	
	local new = {}
	
	for x,y in range(1,1,100,100) do
		
		local count = 0
		
		for _,off in ipairs(offsets) do
			local neighbour = grid [ (x+off[1]) .. ":" .. (y+off[2]) ]
			if neighbour then
				count = count + 1
			end
		end
		
		local here = grid[x .. ":" .. y]
		
		if here then
			new[x .. ":" .. y] = count == 2 or count == 3
		else
			new[x .. ":" .. y] = count == 3
		end
		
	end
	
	if part_2 then
		new["1:1"] = true
		new["1:100"] = true
		new["100:1"] = true
		new["100:100"] = true
	end
	
	return new
end

local function count_on(grid)
	local count = 0
	
	for k,v in pairs(grid) do
		if v then
			count = count + 1
		end
	end
	
	return count
end

local function run(part_2)
	
	local grid = load_data()
	
	for i = 1,100 do
		grid = iterate(grid, part_2)
	end
	
	print(count_on(grid))
end

run()
run(true)