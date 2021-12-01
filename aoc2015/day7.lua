local function treat_param(p, add_brackets)

	if tonumber(p) then
		return p
	else
		return "wire_" .. p .. (add_brackets and "()" or "")
	end

end

local memo_table = {}
function memo(f)
	return function()
		local prev = memo_table[f]
		if prev then
			return prev
		end

		local result = f()

		memo_table[f] = result

		return result
	end
end

local ops =
{
	AND = "&",
	OR = "|",
	NOT = "~",
	LSHIFT = "<<",
	RSHIFT = ">>"
}

local function treat_binop(a,op,b,c)

	return string.format(
		"%s = memo(function() return (%s %s %s) & 0xFFFF end)",
		treat_param(c),
		treat_param(a, true),
		ops[op],
		treat_param(b, true)
	)

end

local function treat_monop(op,a,b)

	return string.format(
		"%s = memo(function() return (%s %s) & 0xFFFF end)",
		treat_param(b),
		ops[op],
		treat_param(a, true)
	)

end

local function treat_assign(a,b)

	return string.format(
		"%s = memo(function() return %s & 0xFFFF end)",
		treat_param(b),
		treat_param(a, true)
	)

end

local function parse_line(line)

	local a,op,b,c = line:match "(%w+) (%w+) (%w+) %-> (%w+)"
	if a and op and b and c then
		return treat_binop(a,op,b,c)
	end

	local op,a,b = line:match "(%w+) (%w+) %-> (%w+)"
	if op and a and b then
		return treat_monop(op,a,b)
	end

	local a,b = line:match "(%w+) %-> (%w+)"
	if a and b then
		return treat_assign(a,b)
	end

	error("Couldn't parse: " .. line)
end

local function part1()

	local source_lines = {}

	for line in io.lines "day7.txt" do
		table.insert(source_lines, parse_line(line))
	end

	table.insert(source_lines, string.format("return %s", treat_param("a", true)))

	local source = table.concat(source_lines, "\n")
	local fun,err = load(source)

	if not fun then
		print(err)
	end
	
	return source, fun()
end

local function part2()
	
	print "===== Part 1 ====="
	
	local source, a_value = part1()
	print(source)
	
	print("Wire a: ", a_value)
	
	print "===== Part 2 ====="
	print "Memo table reset"
	print(string.format("wire_b = function() return %s end", a_value))
	
	wire_b = function() return a_value end
	memo_table = {}
	
	print("New wire a:", wire_a())
end

part2()