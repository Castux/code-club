local anagrams = require "anagrams"

local function main(args)

	local dict_path = args[1]
	local phrase = args[2]
	local includes = {}
	local excludes = {}
	local min_len = 1

	if not dict_path or not phrase then
		print("Usage: lua main.lua <dict_path> <phrase> [+include] [-exclude] [>min_len]")
		return
	end

	for i = 3,#args do

		local head,tail = args[i]:sub(1,1), args[i]:sub(2)

		if head == "+" then
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
	for line in io.lines(dict_path) do
		table.insert(words, line)
	end

	local iter = anagrams.find(words, phrase, includes, excludes, min_len)

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
