local anagrams = require "anagrams"

local function main(args)

	local dict_path = args[1]
	local phrase = args[2]
	local includes = {}
	local excludes = {}
	local min_len = 1
	local ignore_diacritics
	local collapse

	if not dict_path or not phrase then
		print("Usage: lua main.lua <dict_path> <phrase> [+include] [-exclude] [>min_len] [--ignore_diacritics] [--collapse]")
		return
	end

	for i = 3,#args do

		local head,tail = args[i]:sub(1,1), args[i]:sub(2)

		if args[i] == "--ignore_diacritics" then
			ignore_diacritics = true
		elseif args[i] == "--collapse" then
			collapse = true
		elseif head == "+" then
			table.insert(includes, tail)
		elseif head == "-" then
			table.insert(excludes, tail)
		elseif head == ">" then
			min_len = tonumber(tail)
		else
			print("Unexpected argument: " .. args[i])
			return
		end
	end

	local words = {}
	local str = io.open(dict_path, "r"):read "*a"
	for word in str:gmatch("[^\r\n]+") do
		table.insert(words, word)
	end

	local config =
	{
		includes = includes,
		excludes = excludes,
		min_len = min_len,
		ignore_diacritics = ignore_diacritics,
		collapse = collapse
	}

	local dictionary = anagrams.load_dict(words, config)
	local iter = anagrams.find(dictionary, phrase, config)

	if not iter then
		print("Includes are too restrictive")
		return
	end

	for res in iter do

		if res ~= "pause" then

			for _,v in ipairs(includes) do
				io.write(v, " ")
			end

			for _,v in ipairs(res) do
				io.write(table.concat(v.strings, "/"), " ")
			end
			io.write "\n"
		end

	end
end

main({...})
