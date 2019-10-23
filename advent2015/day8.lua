
local code_chars = 0
local memory_chars = 0
local escaped_chars = 0

for line in io.lines "day8.txt" do
	
	code_chars = code_chars + #line
	
	local fun,err = load("return " .. line)
	
	if not fun then
		error(err)
	end
	
	local str = fun()
	
	memory_chars = memory_chars + #str
	
	local escape = string.format('%q', line)
	escaped_chars = escaped_chars + #escape
end

print("Part 1", code_chars, memory_chars, code_chars - memory_chars)
print("Part 2", escaped_chars, code_chars, escaped_chars - code_chars)