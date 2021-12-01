local function load_data()

	local ingredients = {}

	for line in io.lines "day15.txt" do
		local name, capacity, durability, flavor, texture, calories =
		line:match "(%w+): capacity ([-%d]+), durability ([-%d]+), flavor ([-%d]+), texture ([-%d]+), calories ([-%d]+)"

		table.insert(ingredients,
			{
				name = name,
				capacity = tonumber(capacity),
				durability = tonumber(durability),
				flavor = tonumber(flavor),
				texture = tonumber(texture),
				calories = tonumber(calories)
			})
	end

	return ingredients
end

local function split(total, parts)
	
	local result = {}
	local function split_rec(total, parts)

		if parts == 1 then

			result[#result + 1] = total
			coroutine.yield(result)
			result[#result] = nil

			return
		end

		for i = 0,total do
			result[#result + 1] = i
			split_rec(total - i, parts - 1)
			result[#result] = nil
		end
	end

	return coroutine.wrap(function() split_rec(total, parts) end)
end

local function score(quantities, ingredients, calories_wanted)

	assert(#quantities == #ingredients)
	local cookie_score = 1

	for property in pairs(ingredients[1]) do
		if property ~= "name" then

			local prop_score = 0
			for i,ingredient in ipairs(ingredients) do

				prop_score = prop_score + quantities[i] * ingredient[property]

			end

			if prop_score < 0 then
				prop_score = 0
			end

			if property ~= "calories" then
				cookie_score = cookie_score * prop_score
			elseif calories_wanted and prop_score ~= calories_wanted then
				cookie_score = 0
				break
			end
		end
	end

	return cookie_score
end

local function run(calories_wanted)

	local ingredients = load_data()
	local best = math.mininteger

	for s in split(100, #ingredients) do
		local score = score(s, ingredients, calories_wanted)

		best = math.max(best, score)
	end

	print(best)
end

run()
run(500)