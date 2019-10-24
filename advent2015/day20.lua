-- It looks like even numbers are always higher than the two odds around,
-- so let's only check even numbers. Also if k divides i, then (i/k) divides i as well.
-- But sometimes it's the same divisor (if i is a square), so don't count it twice.

local function part1()

	for i = 2,math.maxinteger,2 do

		local sum = 0

		for k = 1,math.sqrt(i) do

			if i % k == 0 then

				local conjugate = i // k
				if k == conjugate then
					sum = sum + k
				else
					sum = sum + k + conjugate
				end

			end

		end

		if 10 * sum >= 36000000 then
			print(i)
			break
		end

	end
end

local function part2()

	for i = 2,math.maxinteger,2 do

		local sum = 0

		for k1 = 1,math.sqrt(i) do
			if i % k1 == 0 then

				local k2 = i // k1

				if k1 == k2 then
					if 50 * k1 >= i then
						sum = sum + k1
					end
				
				else

					if 50 * k1 >= i then
						sum = sum + k1
					end

					if 50 * k2 >= i then
						sum = sum + k2
					end

				end

			end
		end

		if 11 * sum >= 36000000 then
			print(i)
			break
		end

	end
end

part1()
part2()