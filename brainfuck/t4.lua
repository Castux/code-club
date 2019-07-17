local langkit = require "langkit"
local parser = require "t4parser"

local function setError(env, msg, token)

	if token then
		local line,txt,under = langkit.context(token)
		env.errorMessage = string.format("%s:%d: %s:\n%s\n%s\n", token.source.origin, line, msg, txt, under)
	else
		env.errorMessage = msg
	end

	error()
end

local function emit(env, op)
	table.insert(env.ops, op)
end

local function emitDebug(env, str, ...)

	if not env.debug then
		return
	end

	local tabs = string.rep("|   ", env.debugIndent)

	local str = "\n" .. tabs .. str:format(...) .. "        "
	emit(env, str)
end

local function emitIndent(env, delta)
	env.debugIndent = env.debugIndent + delta
end

local function getIndex(env, variable)

	local frame = env.frames[#env.frames]
	local index = frame[variable.value]
	if not index then
		setError(env, "unknown variable " .. variable.value, variable)
	end

	return index
end

local function getRegisterIndex(env, n)

	-- Not really registers, but cells above the current frame
	-- r1, r2, r3, etc.

	local frame = env.frames[#env.frames]
	return frame["@top"] + n
end

local function movePointer(env, index)
	local currentIndex = env.pointer
	local diff = index - currentIndex

	if diff > 0 then
		emit(env, string.rep(">", diff))
	elseif diff < 0 then
		emit(env, string.rep("<", -diff))
	end

	env.pointer = index
end

local function movePointerToVariable(env, dest)

	movePointer(env, getIndex(env, dest))
end

local function setToConstant(env, index, value)

	movePointer(env, index)
	emit(env, "[-]")
	emit(env, string.rep("+", value))
end

local function emitReset(env, indices)

	for i,v in ipairs(indices) do
		movePointer(env, v)
		emit(env, "[-]")
	end
end

local function compileSet(env, op)

	local operator = op.moveOp.value

	local indices = {}
	local names = {}

	for i,v in ipairs(op.right) do
		indices[i] = getIndex(env, v)
		names[i] = v.value
	end

	emitDebug(env, "%s %s to %s", operator == "~>>" and "add" or "set", op.value.value, table.concat(names, " "))

	if operator == "~>" then
		emitReset(env, indices)
	end

	for _,dest in ipairs(indices) do
		movePointer(env, dest)
		emit(env, string.rep("+", tonumber(op.value.value)))
	end
end

local function emitMove(env, from, indices)

	-- Remove all occurences of from in the indices

	local i = 1
	while i <= #indices do
		if indices[i] == from then
			table.remove(indices, i)
		else
			i = i +1
		end
	end

	-- Ignore a nop

	if #indices == 0 then
		return
	end

	-- Perform move!

	movePointer(env, from)
	emit(env, "[-")
	for i,v in ipairs(indices) do
		movePointer(env, v)
		emit(env, "+")
	end
	movePointer(env, from)
	emit(env, "]")

end

local function compileMoveCopy(env, op)

	local operator = op.moveOp.value
	local restoreSource
	local resetDest

	if operator == "->" or operator == "~>" then
		resetDest = true
	end

	if operator == "->" or operator == "->>" then
		restoreSource = true
	end

	local from = getIndex(env, op.left)

	local indices = {}
	local names = {}

	for i,v in ipairs(op.right) do
		indices[i] = getIndex(env, v)
		names[i] = v.value
	end
	
	emitDebug(env, "%s%s %s to %s", restoreSource and "copy" or "move", resetDest and "reset" or "add", op.left.value, table.concat(names, " "))

	-- Clean up destinations

	if resetDest then
		emitReset(env, indices)
	end

	-- For a copy, prepare a temp storage

	local r1 = getRegisterIndex(env, 1)
	if restoreSource then
		emitReset(env, { r1 })
		table.insert(indices, r1)
	end

	-- Main move

	emitMove(env, from, indices)

	-- For a copy, restore the original

	if restoreSource then
		emitMove(env, r1, { from })
	end
end

local compileOperation

local function compileWhile(env, op)

	emitDebug(env, "while %s", op.variable.value)
	emitIndent(env, 1)

	local conditionIndex = getIndex(env, op.variable)

	movePointer(env, conditionIndex)
	emit(env, "[")
	for i,v in ipairs(op.body) do
		compileOperation(env, v)
	end

	emitIndent(env, -1)
	emitDebug(env, "while %s", op.variable.value)

	movePointer(env, conditionIndex)
	emit(env, "]")

end

local compileFunction

local function compileCall(env, op)

	-- Copy the arguments to the frame above us
	-- Same indices as r1, r2, ...

	for i,arg in ipairs(op.arguments) do
		if arg.name == "number" then

			emitDebug(env, "setup arg %d", arg.value)
			setToConstant(env, getRegisterIndex(env, i), tonumber(arg.value))
		else
			emitDebug(env, "setup arg %s", arg.value)

			local from = getIndex(env, arg)
			local to = getRegisterIndex(env, i)
			local using = getRegisterIndex(env, i+1)
			
			emitReset(env, {to,using})
			emitMove(env, from, {to,using})
			emitMove(env, using, {from})
		end
	end

	emitDebug(env, "call %s", op.func.value)

	-- Point to the base of the next frame
	local r1 = getRegisterIndex(env,1)
	movePointer(env, r1)

	emitIndent(env, 1)
		
	-- And that's it!
	compileFunction(env, op.func.value, op.func)

	emitIndent(env, -1)

	-- Return value is in r1
	if #op.right > 0 then

		local destinations = {}
		local names = {}

		for i,v in ipairs(op.right) do
			table.insert(destinations, getIndex(env,v))
			names[i] = v.value
		end

		local reset = op.moveOp.value == "~>"

		emitDebug(env, "move%s ret to %s", reset and "reset" or "add", table.concat(names, " "))
		if reset then
			emitReset(env, destinations)
		end
		emitMove(env, r1, destinations)
	end

	emitDebug(env, "exit %s", op.func.value)
end

local function compileReturn(env, op)

	emitDebug(env, "return %s", op.variable.value)

	-- We leave the return value in the first cell of the frame
	-- Which will be r1 for the caller
	
	local from = getIndex(env, op.variable)
	local bottom = env.frames[#env.frames]["@bottom"]
	
	if from == bottom then
		return
	end
	
	emitReset(env, {bottom})
	emitMove(env, from, {bottom})
end

compileOperation = function(env, op)

	if op.op == "set" then
		compileSet(env,op)
	elseif op.op == "movecopy" then
		compileMoveCopy(env,op)
	elseif op.op == "+" or op.op == "-" then
		emitDebug(env, op.op == '+' and "incr %s" or "decr %s", op.variable.value)
		movePointerToVariable(env, op.variable)
		emit(env, string.rep(op.op, op.count))
	elseif op.op == "in" then
		emitDebug(env, "in %s" , op.variable.value)
		movePointerToVariable(env, op.variable)
		emit(env, ",")
	elseif op.op == "out" then
		emitDebug(env, "out %s" , op.variable.value)
		movePointerToVariable(env, op.variable)
		emit(env, ".")
	elseif op.op == "while" then
		compileWhile(env, op)
	elseif op.op == "call" then
		compileCall(env, op)
	elseif op.op == "return" then
		compileReturn(env, op)
	elseif op.op == "?" then
		emitDebug(env, "debug")
		emit(env, "?")
	end

end

compileFunction = function(env, name, token)

	-- Does it exist?

	local func = env.functions[name]
	if not func then
		setError(env, "unknown function " .. name, token)
	end

	-- Collect variables

	local variables = {}
	for _,v in ipairs(func.arguments) do
		table.insert(variables, v.value)
	end
	for _,v in ipairs(func.locals) do
		table.insert(variables, v.value)
	end

	-- Base pointer for the frame

	local frameIndex = env.pointer

	-- Name to index lookup

	local frame = {}

	for i,v in ipairs(variables) do
		frame[v] = frameIndex + i - 1
	end

	-- Where is the frame

	frame["@bottom"] = frameIndex
	frame["@top"] = frameIndex + #variables - 1

	-- Push stack

	table.insert(env.frames, frame)

	-- Rock'n'roll

	for _,op in ipairs(func.ops) do
		compileOperation(env, op)
	end

	-- Tear down

	table.remove(env.frames)
end

local function compile(files, debug)

	local functions = {}

	for _,file in ipairs(files) do
		local funcs = parser.run(file)
		if not funcs then
			return
		end
		for i,func in ipairs(funcs) do
			functions[func.name.value] = func
		end
	end

	local env =
	{
		functions = functions,
		frames = {},
		pointer = 1,
		ops = {},
		errorMessage = nil,
		debug = debug,
		debugIndent = 0
	}

	local success,result = pcall(compileFunction, env, "main")
	--compileFunction(env, "main")
	if not success then
		print(env.errorMessage or "internal error: " .. result)
		return
	else

	end

	return table.concat(env.ops)
end

return
{
	compile = compile
}