local lk = require "langkit"

local source = lk.readFile "test.t4"

for i,v in ipairs(source.lines) do
	print(i,v)
end

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

local tokens, err = lk.lex(source, lexRules)
if err then
	local line, txt, under = lk.context(err)
	print("Lexer error: " .. err.source.origin .. ":" .. line .. ": unexpected character")
	print(txt)
	print(under)
	
	return
end

for i,v in ipairs(tokens) do
	local line, txt, under = lk.context(v)
	print(line)
	print(txt)
	print(under)
	
end