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

local function compileSet(env, op)
	
	for _,dest in ipairs(op.right) do
		movePointerToVariable(env, dest)
		emit(env, "[-]")
		emit(env, string.rep("+", tonumber(op.value.value)))
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
		movePointer(env, v)
		emit(env, "+")
	end
	movePointer(env, from)
	emit(env, "]")
	
end

local function compileCopy(env, op)
	
	local indices = {}
	for i,v in ipairs(op.right) do
		indices[i] = getIndex(env, v)
	end
	
	-- Also r1 as tmp destination
	local r1 = getRegisterIndex(env, 1)
	table.insert(indices, r1)
	
	local from = getIndex(env, op.left)
	
	-- First clear all destinations
	
	for i,v in ipairs(indices) do
		movePointer(env,v)
		emit(env, "[-]")
	end
	
	-- Destructively move source to destinations + r1
	
	movePointer(env, from)
	emit(env, "[-")
	for i,v in ipairs(indices) do
		movePointer(env, v)
		emit(env, "+")
	end
	movePointer(env, from)
	emit(env, "]")
	
	-- Move back r1 to origin
	
	movePointer(env, r1)
	emit(env, "[-")
	movePointer(env, from)
	emit(env, "+")
	movePointer(env, r1)	
	emit(env, "]")
	
end

local function compileOperation(env, op)
	
	if op.op == "set" then
		compileSet(env,op)
	elseif op.op == "~>" then
		compileMove(env,op)
	elseif op.op == "->" then
		compileCopy(env,op)
	end
	
end

local function compileFunction(env, name, token)
	
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