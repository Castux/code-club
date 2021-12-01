local function table_copy(t)

	local res = {}
	for k,v in pairs(t) do
		res[k] = v
	end

	return res
end

local function load_data()

	local weights = {}
	local total = 0
	for line in io.lines "day24.txt" do
		table.insert(weights, tonumber(line))
		total = total + tonumber(line)
	end
	return weights,total
end

local function split(weights, total)

	local result = {}
	local function split_rec(total, start_at)

		if total < 0 then
			return
		end

		if total == 0 then
			coroutine.yield(result, weights)
			return
		end

		for i = start_at,#weights do

			local v = weights[i]

			table.insert(result, v)
			table.remove(weights, i)

			split_rec(total - v, i)

			table.insert(weights, i, v)
			table.remove(result)

		end
	end

	return coroutine.wrap(function() split_rec(total, 1) end)
end

local function product(arr)
	local prod = 1
	for i,v in ipairs(arr) do
		prod = prod * v
	end

	return prod
end

local function part1()

	local weights, total = load_data()

	table.sort(weights, function(a,b) return a > b end)

	local each = total // 3
	assert(total == each * 3)

	local smallest
	local best_qe

	for group1,rest in split(weights, each) do

		if smallest and #group1 > smallest then
			goto continue
		end

		for group2,group3 in split(table_copy(rest), each) do

			-- There is at least one solution with this group1

			if not smallest or #group1 < smallest then
				smallest = #group1
				best_qe = math.maxinteger
			end

			if #group1 == smallest then
				local qe = product(group1)
				best_qe = math.min(qe, best_qe)
			end

			goto continue -- we only need to know that there's 1 solution per group1
		end

		::continue::
	end

	print(best_qe)
end


local function part2()

	local weights, total = load_data()

	table.sort(weights, function(a,b) return a > b end)

	local each = total // 4
	assert(total == each * 4)

	local smallest
	local best_qe

	for group1,rest in split(weights, each) do

		if smallest and #group1 > smallest then
			goto continue
		end

		for group2,rest2 in split(table_copy(rest), each) do
			for group3,rest3 in split(table_copy(rest2), each) do

				if not smallest or #group1 < smallest then
					smallest = #group1
					best_qe = math.maxinteger
				end

				if #group1 == smallest then
					local qe = product(group1)
					best_qe = math.min(qe, best_qe)
				end

				goto continue -- We don't need all solutions, just to know there's at least one
			end
		end

		::continue::
	end

	print(best_qe)
end

part1()
part2()