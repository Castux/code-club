local function load_data()

	local prog = {}

	for line in io.lines "day23.txt" do

		local op,reg,off = line:match "(%w+) (%w), ([+-]%d+)"
		if op and reg and off then
			table.insert(prog, {op = op, reg = reg, off = tonumber(off)})
			goto continue
		end

		local op,reg = line:match "(%w+) (%w)"
		if op and reg then
			table.insert(prog, {op = op, reg = reg})
			goto continue
		end

		local op,off = line:match "(%w+) ([+-]%d+)"
		if op and off then
			table.insert(prog, {op = op, off = tonumber(off)})
			goto continue
		end

		error("Bad op: " .. line)

		::continue::
	end

	return prog
end

local function run(part_2)

	local prog = load_data()
	local regs = { a = 0 , b = 0 }

	if part_2 then
		regs.a = 1
	end

	local pc = 1

	while pc <= #prog do

		local op = prog[pc]

		if op.op == "hlf" then
			regs[op.reg] = regs[op.reg] // 2
			pc = pc + 1

		elseif op.op == "tpl" then
			regs[op.reg] = regs[op.reg] * 3
			pc = pc + 1

		elseif op.op == "inc" then
			regs[op.reg] = regs[op.reg] + 1
			pc = pc + 1

		elseif op.op == "jmp" then
			pc = pc + op.off

		elseif op.op == "jie" then		
			if regs[op.reg] % 2 == 0 then
				pc = pc + op.off
			else
				pc = pc + 1
			end

		elseif op.op == "jio" then		
			if regs[op.reg] == 1 then
				pc = pc + op.off
			else
				pc = pc + 1
			end

		else
			error("Bad op: " .. op.op)

		end
	end
	
	print(regs.b)
end

run()
run(true)