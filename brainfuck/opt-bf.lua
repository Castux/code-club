-- Remove all non-op characters

local function strip_comments(src)

	local program = {}
	for c in src:gmatch "[<>%+%-%[%]%.,%?]" do
		table.insert(program, c)
	end

	return program
end

-- Combine sequences of +, -, < or > into a single instruction

local function accumulate(src)

	local res = {}

	local i = 1

	local count = function(op)
		local c = 0
		while src[i + c] == op do
			c = c + 1
		end

		return c
	end

	while i <= #src do

		local didit = false

		for _,op in ipairs {'+','-','>','<'} do

			if src[i] == op then
				local c = count(op)
				table.insert(res, {op,c} )
				i = i + c

				didit = true
				break
			end
		end

		if not didit then
			table.insert(res, src[i])
			i = i + 1
		end
	end

	return res
end

-- Replace +/- with a single instruction and </> as well

local function unify(src)

	for i,v in ipairs(src) do
		if v[1] == '+' then
			v[1] = 'add'

		elseif v[1] == '-' then
			v[1] = 'add'
			v[2] = -v[2]

		elseif v[1] == '>' then
			v[1] = 'jump'

		elseif v[1] == '<' then
			v[1] = 'jump'
			v[2] = -v[2]
		end
	end

	return src
end

-- Pre-count loop offsets

local function match_braces(src)

	for i,v in ipairs(src) do

		if src[i] == '[' then

			local depth = 1
			local offset = 0

			while depth > 0 do

				offset = offset + 1

				local c = src[i + offset]
				if c == '[' then
					depth = depth + 1
				elseif c == ']' then
					depth = depth - 1
				elseif c == nil then
					error("unmatched braces")
				end

			end

			src[i] = {'loop', offset}
			src[i + offset] = {'loop', -offset}
		end
	end	

	return src
end

-- Flatten tables into 2-cell opcodes

local function flatten(src)

	local res = {}

	for i,v in ipairs(src) do

		if type(v) ~= "table" then
			table.insert(res, v)
			table.insert(res, " ")
		else
			table.insert(res, v[1])

			if v[1] == 'jump' or v[1] == 'loop' then
				table.insert(res, v[2] * 2)
			else
				table.insert(res, v[2])
			end

		end
	end

	return res
end

local function execute(src)

	local memory = {0}
	local pointer = 1
	local pc = 1

	local function dump()

		for i,v in ipairs(memory) do
			if i == pointer then
				io.write("[" .. v .. "] ")
			else
				io.write(" " .. v .. "  ")
			end
		end

		io.write "\n"
	end

	while true do

		local op = src[pc]
		local arg = src[pc + 1]

		if not op then
			break
		end		

		if op == '.' then
			io.write(string.char(memory[pointer]))
			io.flush()

		elseif op == ',' then
			local c = io.read(1)
			memory[pointer] = c and string.byte(c) or 0

		elseif op == '?' then
			dump()

		elseif op == 'add' then
			memory[pointer] = memory[pointer] + arg
			if memory[pointer] < 0 then error("integer underflow") end

		elseif op == 'jump' then
			pointer = pointer + arg
			if not memory[pointer] then memory[pointer] = 0 end

		elseif op == 'loop' then
			if arg > 0 and memory[pointer] == 0 or
			arg < 0 and memory[pointer] ~= 0 then
				pc = pc + arg
			end

		end	

		pc = pc + 2
	end
end

local function dump(src)
	for i,v in ipairs(src) do
		if type(v) == "table" then
			io.write('{', table.concat(v,','),'}')
		else
			io.write(v)
		end
		io.write(',')
	end
	print ""
end

local function run(src)

	local passes = { strip_comments, accumulate, unify, match_braces, flatten }

	for _,p in ipairs(passes) do
		src = p(src)
--		dump(src)
	end

	execute(src)
end

return
{
	run = run
}
