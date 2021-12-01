local function load_data()

	local sues = {}

	for line in io.lines "day16.txt" do

		local t = {}
		local sue = line:match "Sue (%d+)"

		for prop,count in line:gmatch "(%w+): (%d+)" do
			t[prop] = tonumber(count)
		end

		sues[tonumber(sue)] = t
	end

	return sues
end

local function filter_sues(sues, known_values, is_part_2)

	for i,sue in ipairs(sues) do
		for prop,count in pairs(sue) do

			if is_part_2 then
				if prop == "cats" or prop == "trees" then
					if count <= known_values[prop] then
						sue.invalid = true
						break
					end

				elseif prop == "pomeranians" or prop == "goldfish" then
					if count >= known_values[prop] then
						sue.invalid = true
						break
					end

				else
					if count ~= known_values[prop] then
						sue.invalid = true
						break
					end
				end


			else
				if count ~= known_values[prop] then
					sue.invalid = true
					break
				end
			end

		end
	end

	for i,sue in ipairs(sues) do
		if not sue.invalid then
			print(i)
			return
		end
	end

	print "NO SUE!"
end

local function run(is_part_2)

	local sues = load_data()

	filter_sues(sues,
		{
			children = 3,
			cats = 7,
			samoyeds = 2,
			pomeranians = 3,
			akitas = 0,
			vizslas = 0,
			goldfish = 5,
			trees = 3,
			cars = 2,
			perfumes = 1,
			}, is_part_2)

end

run()
run(true)