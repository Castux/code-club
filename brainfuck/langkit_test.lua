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
	print("gasp: " .. err.value) 
end

for i,v in ipairs(tokens) do
	print(i, v.name, v.value)
end