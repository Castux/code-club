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

local function movePointer(env, dest)
	
	local frame = env.frames[#env.frames]
	local index = frame[dest.value]
	if not index then
		setError(env, "unknown variable " .. dest.value, dest)
	end
	
	local currentIndex = env.pointers[#env.pointers]
	local diff = index - currentIndex
	
	if diff > 0 then
		emit(env, string.rep(">", diff))
	elseif diff < 0 then
		emit(env, string.rep("<", -diff))
	end
	
	env.pointers[#env.pointers] = index	
end

local function compileSet(env, op)
	
	for _,dest in ipairs(op.right) do
		movePointer(env, dest)
		emit(env, "[-]")
		emit(env, string.rep("+", tonumber(op.value.value)))
	end
	
end

local function compileOperation(env, op)
	
	if op.op == "set" then
		compileSet(env,op)
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