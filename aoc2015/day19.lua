local function load_data()

	local rules = {}
	local start

	for line in io.lines "day19.txt" do

		local from,to = line:match "(%w+) => (%w+)"
		if from and to then
			table.insert(rules, {from, to})
		elseif line ~= "" then
			start = line
		end
	end

	return rules, start
end

local function apply_rule(rule, start)

	local index = 1

	while true do
		local b,e = start:find(rule[1], index, true)
		if b and e then

			local result = start:sub(1,b-1) .. rule[2] .. start:sub(e+1)
			coroutine.yield(result)

			index = e + 1
		else
			break
		end
	end
end

local function apply_all_rules(rules, start)

	return coroutine.wrap(function()
			for _,rule in ipairs(rules) do
				apply_rule(rule, start)
			end
		end)

end

local function part1()

	local rules, start = load_data()

	local results = {}

	for result in apply_all_rules(rules, start) do
		results[result] = true
	end

	local count = 0
	for res,_ in pairs(results) do
		count = count + 1
	end

	print(count)
end

local function reduce(molecule, rules_table)

	local count = 0

	while true do
		local subs1 = 0

		for k,v in pairs(rules_table) do
			local subs2

			molecule,subs2 = molecule:gsub(k,v)

			subs1 = subs1 + subs2
			count = count + subs2
		end

		if subs1 == 0 then
			break
		end
	end

	return molecule,count
end

local function part2()

	local rules, target = load_data()
	local tab = {}

	for _,v in ipairs(rules) do
		assert(not tab[v[2]])
		tab[v[2]] = v[1]
	end


	local result, count = reduce(target,tab)	-- this is not deterministic!! :D
	if result == "e" then
		print(count)
	else
		print "Run again?"
	end

end

part1()
part2()