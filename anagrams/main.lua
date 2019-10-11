local anagrams = require "anagrams"

local function main(args)

	local dict_path = args[1]
	local phrase = args[2]

	if not dict_path or not phrase then
		print("Usage: lua main.lua <dict_path> <phrase>")
		return
	end

	for res in anagrams.find(dict_path, phrase) do

		for _,v in ipairs(res) do
			io.write(v.word, " ")
		end
		io.write "\n"

	end
end

main({...})