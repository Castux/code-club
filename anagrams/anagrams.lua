local function table_copy(t)
	local res = {}
	for k,v in pairs(t) do
		res[k] = v
	end

	return res
end

--[[ Words are represented as table of counts of their characters ]]--

local function count_chars(w)

	local counts = {}
	local total = 0

	for pos,code in utf8.codes(w) do
		counts[code] = (counts[code] or 0) + 1
		total = total + 1
	end

	counts.word = w
	counts.total = total

	return counts
end

local function counts_to_string(counts)

	local chars = {}

	for char,count in pairs(counts) do
		if char ~= "word" and char ~= "total" then
			for i = 1,count do
				table.insert(chars, char)
			end
		end
	end

	table.sort(chars)

	for i,v in ipairs(chars) do
		chars[i] = utf8.char(v)
	end

	return table.concat(chars)
end

-- Check if all the letters in a are found in b

local function is_subword(a,b)

	for char,count in pairs(a) do
		if char ~= "word"  and char ~= "total" then

			if count > (b[char] or 0) then
				return false
			end

		end
	end

	return true
end

-- Result is big - small

local function count_diff(big,small)

	local res = {}
	local total = 0

	for char,count in pairs(big) do
		if char ~= "word"  and char ~= "total" then

			local diff = big[char] - (small[char] or 0)
			assert(diff >= 0)

			if diff > 0 then
				res[char] = diff
				total = total + diff
			end

		end
	end

	res.total = total

	return res
end

--[[ Dictionary ]]--

-- All the words, indexed by their length

local function load_dict(path)

	local words = {}
	local count = 0

	for line in io.lines(path) do
		local word = line:match "%w+"
		word = word:lower()

		word = count_chars(word)

		if not words[word.total] then
			words[word.total] = {}
		end

		table.insert(words[word.total], word)
		count = count + 1
	end

	return words,count
end

local function find_all_subwords(dict, word, start_at)

	local res = {}

	-- Only look for words that "come after" start_at: shorter ones, or 
	-- larger lexicographically

	local max_length = start_at and start_at.total or #dict

	for length = max_length,1,-1 do
		for _,w in ipairs(dict[length]) do
			
			local skip = false
			if start_at and length == max_length then
				skip = w.word < start_at.word
			end
			
			if (not skip) and is_subword(w, word) then
				table.insert(res, w)
			end
		end
	end

	return res
end

--[[ The algorithm itself: straightforward recursion ]]--

local function find_anagrams(dict, word, current)

	current = current or {}

	if word.total == 0 then
		coroutine.yield(table_copy(current))
	end

	-- To avoid duplicate answers, always go in decreasing word length
	
	local start_at = current[#current]
	
	local subs = find_all_subwords(dict, word, start_at)

	for _,v in ipairs(subs) do

		local rest = count_diff(word, v)

		current[#current + 1] = v

		find_anagrams(dict, rest, current)

		current[#current] = nil		
	end
end

local function run(dict_path, word)
	
	local dict,count = load_dict(dict_path)
	print("Loaded " .. count .. " words from " .. dict_path)
	
	word = count_chars(word)
	
	return coroutine.wrap(function() find_anagrams(dict, word) end)
end

return
{
	find = run
}