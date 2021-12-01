local function distance_traveled(speed, duration, rest, total_time)

	local cycle = duration + rest
	local full_cycles = total_time // cycle
	local remainder = total_time % cycle

	local time_moving_in_last_cycle = math.min(remainder, duration)

	local time_moving = full_cycles * duration + time_moving_in_last_cycle

	return time_moving * speed
end

local function test()

	assert(distance_traveled(14, 10, 127, 1000) == 1120)
	assert(distance_traveled(16, 11, 162, 1000) == 1056)
end

test()

local function part1()
	local best = math.mininteger
	local winner

	for line in io.lines "day14.txt" do
		local name, speed, duration, rest = line:match "(%w+) can fly (%d+) km/s for (%d+) seconds, but then must rest for (%d+) seconds"

		local dist = distance_traveled(tonumber(speed), tonumber(duration), tonumber(rest), 2503)
		if dist > best then
			best = dist
			winner = name
		end

	end

	print(winner, best)
end

local function part2()
	
	local reindeers = {}
	
	for line in io.lines "day14.txt" do
		local name, speed, duration, rest = line:match "(%w+) can fly (%d+) km/s for (%d+) seconds, but then must rest for (%d+) seconds"

		reindeers[name] =
		{
			speed = tonumber(speed),
			duration = tonumber(duration),
			rest = tonumber(rest),
			points = 0
		}
	end
	
	for time = 1,2503 do
		local leader
		local best_distance = math.mininteger
		
		for name,t in pairs(reindeers) do
			local dist = distance_traveled(t.speed, t.duration, t.rest, time)
			if dist > best_distance then
				best_distance = dist
				leader = name
			end
		end
		
		reindeers[leader].points = reindeers[leader].points + 1
	end
	
	local winning_score = math.mininteger
	local winner
	for k,v in pairs(reindeers) do
		if v.points > winning_score then
			winning_score = v.points
			winner = k
		end
	end
	
	print(winner, winning_score)
end

part1()
part2()