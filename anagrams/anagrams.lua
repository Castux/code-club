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
	local diffs = {}

	-- Only look for words that "come after" start_at: shorter ones, or 
	-- larger lexicographically

	local max_length = start_at and #start_at or #dict

	for length = max_length,1,-1 do
		for _,w in ipairs(dict[length]) do

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

local function find_anagrams(dict, word, current, excludes)

	if #word == 0 then
		coroutine.yield(current)
	end

	-- To avoid duplicate answers, always go in decreasing word length

	local start_at = current[#current]

	local subs,diffs = find_all_subwords(dict, word, start_at)

	for i,subword in ipairs(subs) do
		if not excludes[subword.string] then

			local diff = diffs[i]

			current[#current + 1] = subword
			find_anagrams(dict, diff, current, excludes)
			current[#current] = nil		
		end
	end
end

-- Do not modify the returned array! It is used internally!

local function run(dict_path, word, includes, excludes)

	local dict,count = load_dict(dict_path)
	print("Loaded " .. count .. " words from " .. dict_path)

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

	return coroutine.wrap(function() find_anagrams(dict, word, {}, excludes) end)
end

return
{
	find = run
}