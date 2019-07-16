local function splitLines(text)
	local lines = {}
	local ranges = {}
	local i = 1
	
	while true do
		local j = text:find("\n", i)
		if j then
			table.insert(lines, text:sub(i,j-1))
			table.insert(ranges, {i,j-1})
			i = j + 1
		else
			table.insert(lines, text:sub(i))
			table.insert(ranges, {i,#text})
			break
		end
	end
	
	lines.ranges = ranges
	
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

local function lineColumn(source, index)
	
	for line,range in ipairs(source.lines.ranges) do
		if index >= range[1] and index <= range[2] then
			return line, index - range[1] + 1
		end
	end
	
	return nil
end

local function context(token, marker)
	
	if not token then
		return nil,nil,nil
	end
	
	local line,from = lineColumn(token.source, token.from)
	local line2,to = lineColumn(token.source, token.to)
	
	assert(line == line2)
	
	local txt = token.source.lines[line]
	local white = txt:gsub("[^\t]", " ")
	local under = white:sub(1,from-1) .. string.rep(marker or "^", to - from + 1) .. white:sub(to+1)
	
	return line, txt, under
end

local function newParser(tokens)
	
	local p =
	{
		tokens = tokens,
		pos = 1,
		errorMessage = nil,
		
		head = function(self)
			return self.tokens[self.pos]
		end,
		
		peek = function(self,name)
			local token = self.tokens[self.pos]
			if token then
				return token.name == name
			end
			
			return false
		end,
		
		eof = function(self)
			return self.pos > #self.tokens
		end,
		
		expect = function(self, name)
			
			local t = self:head()
			if t.name == name then
				self.pos = self.pos + 1
				return t
			else
				local line,txt,under = context(t)
				local msg = string.format("%s:%d: expected %s, found %s instead:\n%s\n%s\n", t.source.origin, line, name, t.name, txt, under)
				self.errorMessage = msg
				error()
			end
		end,
		
		accept = function(self, name)
			local t = self:head()
			if t.name == name then
				self.pos = self.pos + 1
				return t
			end
		end
	}
	
	return p
end

return
{
	readString = readString,
	readFile = readFile,
	lex = lex,
	context = context,
	newParser = newParser
}