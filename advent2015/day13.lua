local function table_copy(t)
	local res = {}
	for k,v in pairs(t) do
		res[k] = v
	end
	return res
end

local function permutations(arr)

	local arr = table_copy(arr)
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

local function count_happiness(order, happiness)

	local sum = 0

	for i = 1,#order do

		local this = order[i]
		local prev,next = order[(i-2) % #order + 1], order[i % #order + 1]

		sum = sum + (happiness[this .. ":" .. prev] or 0) + (happiness[this .. ":" .. next] or 0)
	end

	return sum
end

local function load()

	local people = {}
	local happiness = {}

	for line in io.lines "day13.txt" do

		local a,dir,amount,b = line:match "(%w+) would (%w+) (%d+) happiness units by sitting next to (%w+)"

		people[a] = true
		people[b] = true

		amount = (dir == "gain" and 1 or -1) * tonumber(amount)
		happiness[a .. ":" .. b] = amount

	end

	do
		local tmp = {}
		for name in pairs(people) do
			table.insert(tmp, name)
		end
		people = tmp
	end

	return people, happiness
end

local function run(people, happiness)

	local best = math.mininteger

	for order in permutations(people) do

		if order[1] ~= people[1] then
			-- It is circular, so always start with the same person
			break
		end

		local hap = count_happiness(order, happiness)
		best = math.max(best, hap)
	end

	print(best)
end

local function part1()
	run(load())
end

local function part2()

	local people, happiness = load()
	table.insert(people, "Self")

	run(people, happiness)
end

part1()
part2()