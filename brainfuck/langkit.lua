local function splitLines(text)
	local lines = {}
	local i = 1
	
	while true do
		local j = text:find("\n", i)
		if j then
			table.insert(lines, text:sub(i,j-1))
			i = j + 1
		else
			table.insert(lines, text:sub(i))
			break
		end
	end
	
	return lines
end

local function readString(text, origin)
	
	return
	{
		origin = origin,
		text = text,
		lines = splitLines(text)
	}
end

local function readFile(path)
	
	local fp = io.open(path, 'r')
	if not fp then
		return nil
	end
	
	local text = fp:read '*a'
	
	return readString(text, path)
end

local function lex(source, rules)
	
	local tokens = {}
	local index = 1
	
	local function add(name, value)
		local token =
		{
			name = name,
			value = value,
			from = index,
			to = index + #value - 1,
			source = source
		}
		
		index = index + #value
		
		table.insert(tokens, token)
	end
	
	local function currentCharacter()
		local c = source.text:sub(index, index)
		return
		{
			name = c,
			value = c,
			from = index,
			to = index,
			source = source
		}
	end
	
	while index <= #source.text do
		
		local whitespace = source.text:match("^" .. rules.whitespace, index)
		if whitespace and #whitespace > 0 then
			index = index + #whitespace
			goto continue
		end
		
		for _,pattern in ipairs(rules.static) do
			local found = source.text:find(pattern, index, true)
			if found == index then
				add(pattern, pattern)
				goto continue
			end
		end
		
		for name,pattern in pairs(rules.dynamic) do
			local value = source.text:match("^" .. pattern, index)
			if value then
				add(name, value)
				goto continue
			end
		end
		
		do
			return nil, currentCharacter()
		end
		
		::continue::
	end
	
	return tokens
end

return
{
	readString = readString,
	readFile = readFile,
	lex = lex
}