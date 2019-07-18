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

-- The big'un. Detect standard moves between cells, such as:
-- [-]  [->+-] [->>>++>+<<<<]
-- The T4 language makes extensive use of these, so reducing them
-- is a huge gain. It's in general a common BF technique and in any case,
-- it cannot decrease performance.
-- We transform the loops which move data back and forth between cells units at a time
-- into a direct 'add' instructions, multiplied by the value in the first cell

-- Condition 1: the loop only contains +-<> (no IO, no nested loop)
-- Condition 2: the pointer comes back to the cell it started from (total offset 0)

-- Conveniently, we'll only need to replace the [ and ] instructions, leaving the rest
-- unchanged, so we won't even need to recount the loop matching!

-- It's magic.

local function is_valid_move(src, start)

	local op = src[start]

	if type(op) ~= "table" or op[1] ~= "loop" or op[2] < 0 then
		return false
	end

	local closingBrace = src[start][2]
	local totalOffset = 0

	for i = 1,closingBrace-1 do

		local op = src[start + i]
		if op[1] ~= 'add' and op[1] ~= 'jump' then
			return false
		end

		if op[1] == 'jump' then
			totalOffset = totalOffset + op[2]
		end
	end

	return totalOffset == 0
end

local function detect_moves(src)

	for i,op in ipairs(src) do
		if is_valid_move(src, i) then

			local closingBrace = src[i + op[2]]

			op[1] = 'setmul'
			op[2] = ' '

			closingBrace[1] = 'resetmul'
			closingBrace[2] = ' '
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
	local multiplier = 1

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
			memory[pointer] = memory[pointer] + arg * multiplier
			if memory[pointer] < 0 then error("integer underflow") end

		elseif op == 'jump' then
			pointer = pointer + arg
			if not memory[pointer] then memory[pointer] = 0 end

		elseif op == 'loop' then
			if arg > 0 and memory[pointer] == 0 or
			arg < 0 and memory[pointer] ~= 0 then
				pc = pc + arg
			end

		elseif op == 'setmul' then
			multiplier = memory[pointer]
		
		elseif op == 'resetmul' then
			multiplier = 1

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

	local passes = { strip_comments, accumulate, unify, match_braces, detect_moves, flatten }

	for _,p in ipairs(passes) do
		src = p(src)
	--	dump(src)
	end

	execute(src)
end

return
{
	run = run
}
