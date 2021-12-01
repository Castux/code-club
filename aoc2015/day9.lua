local cities = {}
local distances = {}

local function permutations(arr)
	local res = {}
	local function perm_rec()

		if #arr == 0 then
			coroutine.yield(res)
			return
		end

		for i = 1,#arr do
			local elem = arr[i]
			res[#res + 1] = elem
			table.remove(arr, i)

			perm_rec()

			table.insert(arr, i, elem)
			res[#res] = nil
		end
	end

	return coroutine.wrap(function() perm_rec() end)
end

local function total_dist(cities)

	local sum = 0

	for i = 1,#cities-1 do
		local a,b = cities[i], cities[i+1]
		if a > b then
			a,b = b,a
		end

		sum = sum + distances[a..","..b]
	end

	return sum
end

local function main()

	for line in io.lines "day9.txt" do

		local a,b,dist = line:match "(%w+) to (%w+) = (%d+)"
		dist = tonumber(dist)

		if not (a and b and dist) then
			error(line)
		end

		cities[a] = true
		cities[b] = true

		if a > b then
			a,b = b,a
		end

		distances[a..","..b] = dist

	end

	do
		local tmp = {}
		for k,_ in pairs(cities) do
			table.insert(tmp, k)
		end
		cities = tmp
	end

	local smallest = math.maxinteger
	local largest = math.mininteger

	for cities in permutations(cities) do

		local d = total_dist(cities)

		smallest = math.min(smallest, d)
		largest = math.max(largest, d)
	end

	print(smallest, largest)
end

main()