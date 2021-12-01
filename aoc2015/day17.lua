local function load_data()

	local res = {}
	for line in io.lines "day17.txt" do
		table.insert(res, tonumber(line))
	end

	table.sort(res, function(a,b) return a > b end)

	return res
end

local function fill(total, containers)

	local result = {}
	local function fill_rec(total, start_at)

		if total < 0 then
			return
		end

		if total == 0 then
			coroutine.yield(result)
			return
		end

		for i = start_at, #containers do

			local container = containers[i]

			table.insert(result, container)
			fill_rec(total - container, i+1)
			table.remove(result)
		end

	end

	return coroutine.wrap(function() fill_rec(total, 1) end)
end

local function run()

	local containers = load_data()

	local total = 0
	local counts = {}

	for solution in fill(150, containers) do
		counts[#solution] = (counts[#solution] or 0) + 1
		total = total + 1
	end

	local smallest = math.huge
	local winning_count

	for k,v in pairs(counts) do
		if k < smallest then
			smallest = k
			winning_count = v
		end
	end

	print(total)
	print(winning_count)
end

run()