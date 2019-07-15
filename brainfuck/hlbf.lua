local bf = require "bf"

local function parse(src)
	
	local blocks = {}
	local currentBlock = nil
	
	local index = 1
	local line = 1
	
	while index <= #src do
		
		local c = src:sub(index,index)
		
		if c == "#" then
			
			local comment = src:match("^#[^\n]*", index)
			index = index + #comment
		
		elseif c == '*' then
			index = index + 1
			local name = src:match("^[%w_]+", index)
			if not name then
				error("Expected identifier after # on line " .. line)
			end
			
			local block = { variables = {} }
			blocks[name] = block
			currentBlock = name
			
			index = index + #name
			
			while true do
				
				local ws = src:match("^%s*", index)
				if ws then
					index = index + #ws
				end
				
				local var = src:match("^[%w_]+", index)
				if var then
					table.insert(block.variables, var)
					index = index + #var
				else
					break
				end
				
			end 
		
		elseif c == "!" then
		
			local macro = src:match("^!([%w_]+)", index)
			if not macro then
				error("Expected identifier after ! on line " .. line)
			end
			
			if not currentBlock then
				error("Code outside of a macro on line " .. line)
			end
			
			table.insert(blocks[currentBlock], {"macro", macro})
			index = index + #macro + 1
			
		elseif c == "@" then
			local var = src:match("^@([%w_]+)", index)
			if not var then
				error("Expected identifier after @ on line " .. line)
			end
			
			if not currentBlock then
				error("Code outside of a macro on line " .. line)
			end
			
			table.insert(blocks[currentBlock], {"var", var})
			index = index + #var + 1
		
		elseif c == "\n" then
			
			line = line + 1
			index = index + 1		
		
		elseif c:match "[<>%+%-%[%]%.,%?]" then
			
			if not currentBlock then
				error("Code outside of a block on line " .. line)
			end
			
			table.insert(blocks[currentBlock], c)
			index = index + 1
			
		else
			index = index + 1
		end
		
	end

	return blocks
end

local function inline(blocks)
	
	local out = {}
	
	local function doBlock(b)
		
		local block = blocks[b]
		if not block then
			error("Unknown macro: " .. b)
		end
		
		-- name cells
		
		local locals = {}
		for i,v in ipairs(block.variables) do
			locals[v] = i
		end
		
		-- assume we start at 1
		local currentPosition = 1
		
		local function moveTo(var)
			local target = locals[var]
			if not target then
				error("Unknown variable: " .. var)
			end
			
			local delta = target - currentPosition
			if delta > 0 then
				table.insert(out, string.rep(">", delta))
			elseif delta < 0 then 
				table.insert(out, string.rep("<", -delta))
			end
		end
		
		for _,v in ipairs(block) do
			
			if type(v) == "table" and v[1] == "macro" then
				doBlock(v[2])
			elseif type(v) == "table" and v[1] == "var" then
				moveTo(v[2])
			else
				table.insert(out, v)
			end
			
		end
	end
	
	doBlock "main"
	
	return table.concat(out)
end

local function run(src)
	
	local blocks = parse(src)
	
	bf.run(inline(blocks))
end

return
{
	run = run
}