local langkit = require "langkit"

local lexRules =
{
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

local function parseFunction(p)
	
	p:expect "function"
	local name = p:expect "identifier"
	p:expect "("
	
	local arguments = {}
	if p:peek "identifier" then
		
		repeat
			table.insert(arguments, p:expect "identifier")
		until not p:accept ","
		
	end
	
	local locals = {}
	if p:accept "|" then
		
		repeat
			table.insert(locals, p:expect "identifier")
		until not p:accept ","
	end
	
	
	p:expect ")"
	
	return {name = name, arguments = arguments}
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
		print("Lexer error: " .. err.source.origin .. ":" .. line .. ": unexpected character")
		print(txt)
		print(under)
		return
	end
	
	local parser = langkit.newParser(tokens)
	
	local success,res = pcall(parse, parser)
	if res then
		print(res)
	end
	if not success then
		print(parser.errorMessage)
		return
	end
end

return
{
	run = run
}