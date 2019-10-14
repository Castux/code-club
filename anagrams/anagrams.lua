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
	local space = utf8.codepoint " "

	for pos,code in utf8.codes(w) do
		if code ~= space then
			res[#res + 1] = code
		end
	end

	table.sort(res)
	res.string = w

	return res
end

-- Check if all the letters in a are found in b
-- And return (b - a) if it is the case.
-- We use the fact that both arrays are sorted

local function word_diff(b,a)

	local i,j = 1,1
	local res = {}

	while i <= #a and j <= #b do

		if a[i] < b[j] then			-- the letter in a is not in b: not a subword
			return false


		elseif a[i] == b[j] then	-- found the a letter in b: ignore it in the diff
			i = i+1
			j = j+1

		else						-- a[i] > b[j]: skip the b letter which a doesn't have: add it to the diff
			res[#res + 1] = b[j]
			j = j+1
		end
	end

	if i > #a then 					-- we found all the a letters, add the rest of b to the diff
		for k = j,#b do
			res[#res + 1] = b[k]
		end
		return res

	else							-- we didn't find all the a letter, not a subword
		return nil
	end
end

--[[ Dictionary ]]--

-- All the words, indexed by their length

local function load_dict(words_array)

	if words_array.is_dict then
		return words_array
	end

	local words = {}

	for _,word in ipairs(words_array) do

		word = load_word(word)

		if not words[#word] then
			words[#word] = {}
		end

		table.insert(words[#word], word)
	end

	words.is_dict = true

	return words
end

local function find_all_subwords(dict, word, start_at, min_len, yield_often)

	local res = {}
	local diffs = {}

	-- Only look for words that "come after" start_at: shorter ones, or
	-- larger lexicographically

	local max_length = start_at and #start_at or #dict

	for length = max_length,min_len,-1 do
		for i,w in ipairs(dict[length]) do
			
			if yield_often and i % 5000 == 0 then
				coroutine.yield("pause")
			end

			local skip = false
			if start_at and length == max_length then
				skip = w.string < start_at.string
			end

			if not skip then
				local diff = word_diff(word, w)
				if diff then
					table.insert(res, w)
					table.insert(diffs, diff)
				end
			end
		end
	end

	return res,diffs
end

--[[ The algorithm itself: straightforward recursion ]]--

local function find_anagrams(dict, word, current, excludes, min_len, yield_often)

	if #word == 0 then
		coroutine.yield(current)
	end

	-- To avoid duplicate answers, always go in decreasing word length

	local start_at = current[#current]

	local subs,diffs = find_all_subwords(dict, word, start_at, min_len, yield_often)

	for i,subword in ipairs(subs) do
		
		if not excludes[subword.string] then

			local diff = diffs[i]

			current[#current + 1] = subword
			find_anagrams(dict, diff, current, excludes, min_len, yield_often)
			current[#current] = nil
		end
	end
end

-- Do not modify the returned array! It is used internally!

local function run(dict_words, word, includes, excludes, min_len, yield_often)

	local dict = load_dict(dict_words)

	word = load_word(word)

	include = load_word(table.concat(includes))
	local rest = word_diff(word, include)
	if not rest then
		return nil
	end
	word = rest

	for i,v in ipairs(excludes) do
		excludes[v] = true
	end

	return coroutine.wrap(function() find_anagrams(dict, word, {}, excludes, min_len, yield_often) end)
end

return
{
	load_dict = load_dict,
	find = run
}
