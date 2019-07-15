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
			
			blocks[name] = {}
			currentBlock = name
			
			index = index + #name
		
		elseif c == "!" then
		
			local call = src:match("^![%w_]+", index)
			if not call then
				error("Expected identifier after ! on line " .. line)
			end
			
			if not currentBlock then
				error("Code outside of a macro on line " .. line)
			end
			
			table.insert(blocks[currentBlock], call)
			index = index + #call
		
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
		
		local ops = blocks[b]
		if not ops then
			error("Unknown macro: " .. b)
		end
		
		for _,v in ipairs(ops) do
			
			local call = v:match "^!(.*)"
			if call then
				doBlock(call)
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
	
	for k,v in pairs(blocks) do
		print("#" .. k, table.concat(v))
	end
	
	bf.run(inline(blocks))
end

return
{
	run = run
}