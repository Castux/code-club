local function table_copy(t)
	local res = {}
	for k,v in pairs(t) do
		res[k] = v
	end

	return res
end

--[[ Words are represented as table of counts of their characters ]]--

local function load_word(w)

	local res = {}

	for pos,code in utf8.codes(w) do
		res[#res + 1] = code
	end
	
	table.sort(res)
	res.string = w

	return res
end

-- Check if all the letters in a are found in b
-- We use the fact that both arrays are sorted

local function is_subword(a,b)

	local i,j = 1,1
	
	while i <= #a and j <= #b do
		
		if a[i] < b[j] then		-- the letter in a is not in b
			return false
		
		
		elseif a[i] == b[j] then	-- found the a letter in b
			i = i+1
			j = j+1
		
		else					-- a[i] > b[j]: skip the b letter which a doesn't have
			j = j+1
		end
	end
	
	return i > #a	-- we found all the a letters
end

-- Subtract words (assume small is a subword of big, and they are both sorted)

local function word_diff(b,a)
	
	local res = {}
	
	local i,j = 1,1
	
	while j <= #b do
		
		if b[j] == a[i] then	-- skip it, since it's in small
			-- skip it
			j = j+1
			i = i+1
		elseif i >= #a or b[j] < a[i] then
			res[#res+1] = b[j]
			j = j+1
		else
			i = i+1
		end
		
	end
	
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

		word = load_word(word)

		if not words[#word] then
			words[#word] = {}
		end

		table.insert(words[#word], word)
		count = count + 1
	end

	return words,count
end

local function find_all_subwords(dict, word, start_at)

	local res = {}

	-- Only look for words that "come after" start_at: shorter ones, or 
	-- larger lexicographically

	local max_length = start_at and #start_at or #dict

	for length = max_length,1,-1 do
		for _,w in ipairs(dict[length]) do
			
			local skip = false
			if start_at and length == max_length then
				skip = w.string < start_at.string
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

	if #word == 0 then
		coroutine.yield(current)
	end

	-- To avoid duplicate answers, always go in decreasing word length
	
	local start_at = current[#current]
	
	local subs = find_all_subwords(dict, word, start_at)

	for _,v in ipairs(subs) do

		local rest = word_diff(word, v)
		
		current[#current + 1] = v

		find_anagrams(dict, rest, current)

		current[#current] = nil		
	end
end

-- Do not modify the returned array! It is used internally!

local function run(dict_path, word)
	
	local dict,count = load_dict(dict_path)
	print("Loaded " .. count .. " words from " .. dict_path)
	
	word = load_word(word)
	
	return coroutine.wrap(function() find_anagrams(dict, word) end)
end

return
{
	find = run
}