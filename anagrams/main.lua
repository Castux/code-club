local anagrams = require "anagrams"

local function main(args)

	local dict_path = args[1]
	local phrase = args[2]
	local includes = {}

	if not dict_path or not phrase then
		print("Usage: lua main.lua <dict_path> <phrase> [+include] [-exclude]")
		return
	end

	for i = 3,#args do
		if args[i]:sub(1,1) == "+" then
			table.insert(includes, args[i]:sub(2))
		end		
	end

	local iter = anagrams.find(dict_path, phrase, includes)
	
	if not iter then
		print("Includes are too restrictive")
		return
	end

	for res in iter do
		
		for _,v in ipairs(includes) do
			io.write(v, " ")
		end
		
		for _,v in ipairs(res) do
			io.write(v.string, " ")
		end
		io.write "\n"

	end
end

main({...})