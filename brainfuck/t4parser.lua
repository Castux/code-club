local langkit = require "langkit"

local lexRules =
{
	comment = "#[^\n]*",
	whitespace = "%s*",
	static = 
	{
		"function", "while", "return", "end", "in", "out",
		"~>", "->",
		"(", ")", ",", "|", "-", "+"
	},

	dynamic =
	{
		identifier = "[%a_][%a%d_]*",
		number = "%d+"
	}
}

local function parseIdentifierList(p)
	local ids = {}
	repeat
		table.insert(ids, p:expect "identifier")
	until not p:accept ","
	return ids
end

local function parseMoveCopy(p)

	local left = p:expect "identifier"
	local op = p:accept "~>" or p:expect "->"
	local right = parseIdentifierList(p)

	return {op = op.value, left = left, right = right}
end

local function parseSet(p)
	
	local value = p:expect "number"
	p:expect "->"
	local right = parseIdentifierList(p)

	return {op = "set", value = value, right = right}
end

local function parseCall(p)
	
	local func = p:expect "identifier"
	p:expect "("
	
	local arguments = {}
	if not p:peek ")" then
		repeat
			table.insert(arguments, p:accept "number" or p:expect "identifier")
		until not p:accept ","
	end
	
	p:expect ")"
	
	local right = {}
	if p:accept "->" then
		right = parseIdentifierList(p)
	end
	
	return {op = "call", func = func, arguments = arguments, right = right}
end

local function parseIncrDecr(p)

	local var = p:expect "identifier"

	local op = p:accept "-" or p:expect "+"

	local count = 1
	while p:accept(op.name) do
		count = count + 1
	end

	return {op = op, variable = var, count = count}
end

local function parseIO(p)

	local op = p:accept "in" or p:expect "out"
	local var = p:expect "identifier"

	return {op = op.name, variable = var}
end

local parseOperation

local function parseWhile(p)

	p:expect "while"
	local var = p:expect "identifier"

	local ops = {}
	while not p:peek "end" do
		table.insert(ops, parseOperation(p))
	end

	p:expect "end"

	return {op = "while", variable = var, body = ops}
end

parseOperation = function(p)

	if p:peek "number" then
		return parseSet(p)
	end

	if p:peek "in" or p:peek "out" then
		return parseIO(p)
	end

	if p:peek "while" then
		return parseWhile(p)
	end

	if p:peek "identifier" then
		if p:peek2 "->" or p:peek2 "~>" then
			return parseMoveCopy(p)
		elseif p:peek2 "+" or p:peek2 "-" then
			return parseIncrDecr(p)
		elseif p:peek2 "(" then
			return parseCall(p)
		end
	end

	p:error("invalid operation")
end

local function parseReturn(p)

	p:expect "return"
	local id = p:expect "identifier"

	return {op = "return", variable = id}
end

local function parseFunction(p)

	p:expect "function"
	local name = p:expect "identifier"
	p:expect "("

	local arguments = {}
	if p:peek "identifier" then
		arguments = parseIdentifierList(p)
	end

	local locals = {}
	if p:accept "|" then
		locals = parseIdentifierList(p)
	end

	p:expect ")"

	local ops = {}
	while not p:peek "end" and not p:peek "return" do
		table.insert(ops, parseOperation(p))
	end

	if p:peek "return" then
		table.insert(ops, parseReturn(p))
	end

	p:expect "end"

	return {name = name, arguments = arguments, locals = locals, ops = ops}
end

local function parse(p)

	local functions = {}

	while not p:eof() do
		table.insert(functions, parseFunction(p))		
	end

	return functions
end

local function run(path)

	local source = langkit.readFile "test.t4"
	if not source then
		print("Could not open file: "..path)
		return
	end

	local tokens, err = langkit.lex(source, lexRules)
	if err then
		local line, txt, under = langkit.context(err)
		print(err.source.origin .. ":" .. line .. ": unexpected character")
		print(txt)
		print(under)
		return
	end

	local parser = langkit.newParser(tokens)

	local success,program = pcall(parse, parser)
	if not success then
		print(parser.errorMessage)
		return
	end
	
	return program
end

return
{
	run = run
}