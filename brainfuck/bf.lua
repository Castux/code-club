local function run(src)

	local program = {}
	for c in src:gmatch "[<>%+%-%[%]%.,%?]" do
		table.insert(program, c)
	end

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

		local op = program[pc]
		if not op then
			break
		end

		if op == '<' then
			pointer = pointer - 1
			if not memory[pointer] then
				memory[pointer] = 0
			end

		elseif op == '>' then
			pointer = pointer + 1
			if not memory[pointer] then
				memory[pointer] = 0
			end

		elseif op == '+' then
			memory[pointer] = memory[pointer] + 1

		elseif op == '-' then
			memory[pointer] = memory[pointer] - 1
			if memory[pointer] < 0 then
				error("Integer underflow")
			end

		elseif op == '.' then
			io.write(string.char(memory[pointer]))
			io.flush()

		elseif op == ',' then
			local c = io.read(1)
			memory[pointer] = c and string.byte(c) or 0

		elseif op == '[' then
			if memory[pointer] == 0 then

				local depth = 1
				while depth > 0 do

					pc = pc + 1

					if pc > #program then
						error("Unmatched braces")
					end

					if program[pc] == '[' then
						depth = depth + 1
					elseif program[pc] == ']' then
						depth = depth - 1
					end
				end
			end
			
		elseif op == ']' then
			if memory[pointer] ~= 0 then

				local depth = 1
				while depth > 0 do

					pc = pc - 1

					if pc < 0 then
						error("Unmatched braces")
					end

					if program[pc] == '[' then
						depth = depth - 1
					elseif program[pc] == ']' then
						depth = depth + 1
					end
				end
			end
			
		elseif op == '?' then
			dump()
		end
		
		pc = pc + 1
	end
end

return
{
	run = run
}