local char_classes =
{
	a = "àäáåâ",
	e = "éèëê",
	i = "îïíì",
	o = "ôóòö",
	u = "úùûü",
	c = "ç",
}

local ignores = " -'!.,;:?"

do
	local tmp = {}
	for k,v in pairs(char_classes) do

		for _,code in utf8.codes(v) do
			tmp[code] = utf8.codepoint(k)
		end

	end
	char_classes = tmp

	local tmp = {}
	for _,code in utf8.codes(ignores) do
		tmp[code] = true
	end

	ignores = tmp
end

--[[ Words are represented as table of counts of their characters ]]--

local function load_word(w, config)

	local res = {}

	for _,code in utf8.codes(w) do
		if not ignores[code] then
			res[#res + 1] = config.ignore_diacritics and char_classes[code] or code
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

-- All the words, in decreasing order of sizes

local function load_dict(words_array, config)

	if words_array.is_dict then
		return words_array
	end

	local sizes = {}
	local largest = 1

	for i,word in ipairs(words_array) do

		if config.yield_often and i % 3000 == 0 then
			coroutine.yield(i)
		end

		word = load_word(word, config)

		if not sizes[#word] then
			sizes[#word] = {}
			largest = math.max(largest, #word)
		end

		table.insert(sizes[#word], word)
	end

	local words = {}
	words.is_dict = true

	for size = largest,1,-1 do
		if sizes[size] then
			for _,word in ipairs(sizes[size]) do
				table.insert(words, word)
			end
		end
	end

	return words
end

local function filter_dict_by_size(dict, min_len)

	local res = {}

	for _,v in ipairs(dict) do
		if #v < min_len then
			break
		end

		res[#res + 1] = v
	end
	return res
end

-- Return only the subwords of `word`. This is a still a valid dictionary.
-- To avoid duplicate answers, always go in decreasing order

local function filter_dict(dict, word, start_at, config)

	local res = {}
	local diffs = {}

	local start_index = 1

	if start_at then
		while dict[start_index] ~= start_at do
			start_index = start_index + 1
		end
	end

	for i = start_index,#dict do

		local v = dict[i]
		if config.yield_often and i % 5000 == 0 then
			coroutine.yield("pause")
		end

		local diff = word_diff(word, v)
		if diff then
			table.insert(res, v)
			table.insert(diffs, diff)
		end

	end

	return res,diffs
end

--[[ The algorithm itself: straightforward recursion ]]--

local function find_anagrams(dict, word, current, config)

	if #word == 0 then
		coroutine.yield(current)
		return
	end

	local start_at = current[#current]

	local subs,diffs = filter_dict(dict, word, start_at, config)

	for i,subword in ipairs(subs) do

		if not config.excludes[subword.string] then

			local diff = diffs[i]

			-- The trick is to pass the filtered dictionary down the recursion.
			-- The subwords of the "rest" are a subset of the subwords of the whole.

			current[#current + 1] = subword
			find_anagrams(subs, diff, current, config)
			current[#current] = nil
		end
	end
end

-- Do not modify the returned array! It is used internally!

local function run(dict_words, word, config)

	local dict = load_dict(dict_words, config)
	dict = filter_dict_by_size(dict, config.min_len)

	word = load_word(word, config)

	local include = load_word(table.concat(config.includes), config)
	local rest = word_diff(word, include)
	if not rest then
		return nil
	end
	word = rest

	for i,v in ipairs(config.excludes) do
		config.excludes[v] = true
	end

	return coroutine.wrap(function() find_anagrams(dict, word, {}, config) end)
end

return
{
	load_dict = load_dict,
	find = run
}
