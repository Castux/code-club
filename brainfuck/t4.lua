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

	local frame = env.frames[#env.frames]
	return #frame + n
end

local function movePointer(env, index)
	local currentIndex = env.pointers[#env.pointers]
	local diff = index - currentIndex

	if diff > 0 then
		emit(env, string.rep(">", diff))
	elseif diff < 0 then
		emit(env, string.rep("<", -diff))
	end

	env.pointers[#env.pointers] = index	
end

local function movePointerToVariable(env, dest)

	movePointer(env, getIndex(env, dest))
end

local function setToConstant(env, index, value)

	movePointer(env, index)
	emit(env, "[-]")
	emit(env, string.rep("+", value))
end

local function compileSet(env, op)

	for _,dest in ipairs(op.right) do
		setToConstant(env, getIndex(env, dest), tonumber(op.value.value))
	end

end

local function compileMove(env, op)

	local indices = {}
	for i,v in ipairs(op.right) do
		indices[i] = getIndex(env, v)
	end

	local from = getIndex(env, op.left)

	movePointer(env, from)
	emit(env, "[-")
	for i,v in ipairs(indices) do
		if v ~= from then
			movePointer(env, v)
			emit(env, "+")
		end
	end
	movePointer(env, from)
	emit(env, "]")

end

local function emitCopy(env, from, destinations, tmpIndex)

	table.insert(destinations, tmpIndex)

	-- First clear all destinations

	for i,v in ipairs(destinations) do
		if v ~= from then
			movePointer(env,v)
			emit(env, "[-]")
		end
	end

	-- Destructively move source to destinations + tmp

	movePointer(env, from)
	emit(env, "[-")
	for i,v in ipairs(destinations) do
		if v ~= from then
			movePointer(env, v)
			emit(env, "+")
		end
	end
	movePointer(env, from)
	emit(env, "]")

	-- Move back tmp to origin

	movePointer(env, tmpIndex)
	emit(env, "[-")
	movePointer(env, from)
	emit(env, "+")
	movePointer(env, tmpIndex)	
	emit(env, "]")

end

local function compileCopy(env, op)

	local indices = {}
	for i,v in ipairs(op.right) do
		indices[i] = getIndex(env, v)
	end

	local from = getIndex(env, op.left)

	emitCopy(env, from, indices, getRegisterIndex(env, 1))
end

local compileOperation

local function compileWhile(env, op)

	local conditionIndex = getIndex(env, op.variable)

	movePointer(env, conditionIndex)
	emit(env, "[")
	for i,v in ipairs(op.body) do
		compileOperation(env, v)
	end

	movePointer(env, conditionIndex)
	emit(env, "]")

end

local compileFunction

local function compileCall(env, op)

	-- Copy the arguments to the frame above us
	-- Same indices as r1, r2, ...

	for i,arg in ipairs(op.arguments) do
		if arg.name == "number" then
			setToConstant(env, getRegisterIndex(env, i), tonumber(arg.value))
		else
			local from = getIndex(env, arg)
			local to = getRegisterIndex(env, i)
			local using = getRegisterIndex(env, i+1)
			emitCopy(env, from, {to}, using)
		end
	end

	-- Point to the base of the next frame
	local r1 = getRegisterIndex(env,1)
	movePointer(env, r1)

	-- And that's it?
	compileFunction(env, op.func.value, op.func)
	
	-- Pointer is now at r1. Relatively to us, we need to add the size of our frame
	env.pointers[#env.pointers] = getRegisterIndex(env, 1)
	
	-- Return value is in r1
	
	if #op.right > 0 then
		
		local destinations = {}
		for i,v in ipairs(op.right) do
			table.insert(destinations, getIndex(env,v))
		end
		
		local r2 = getRegisterIndex(env,2)
		emitCopy(env, r1, destinations, r2)
	end

end

compileOperation = function(env, op)

	if op.op == "set" then
		compileSet(env,op)
	elseif op.op == "~>" then
		compileMove(env,op)
	elseif op.op == "->" then
		compileCopy(env,op)
	elseif op.op == "+" or op.op == "-" then
		movePointerToVariable(env, op.variable)
		emit(env, string.rep(op.op, op.count))
	elseif op.op == "in" then
		movePointerToVariable(env, op.variable)
		emit(env, ",")
	elseif op.op == "out" then
		movePointerToVariable(env, op.variable)
		emit(env, ".")
	elseif op.op == "while" then
		compileWhile(env, op)
	elseif op.op == "return" then
		emitCopy(env, getIndex(env, op.variable), {1}, getRegisterIndex(env,1))
		movePointer(env, 1)
	elseif op.op == "call" then
		compileCall(env, op)
	elseif op.op == "?" then
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

	-- Name to index lookup

	for i,v in ipairs(variables) do
		variables[v] = i
	end

	-- Push stack

	table.insert(env.frames, variables)
	table.insert(env.pointers, 1)

	-- Rock'n'roll

	for _,op in ipairs(func.ops) do
		compileOperation(env, op)
	end

	-- Tear down

	table.remove(env.frames)
	table.remove(env.pointers)

end

local function compile(path)

	local program = parser.run(path)

	local functions = {}

	for i,func in ipairs(program) do
		functions[func.name.value] = func
	end

	local env =
	{
		functions = functions,
		frames = {},
		pointers = {},
		ops = {},
		errorMessage = nil
	}

	local success,result = pcall(compileFunction, env, "main")
	print("Internal", result)
	if not success then
		print(env.errorMessage)
		return
	end

	return table.concat(env.ops)
end

return
{
	compile = compile
}