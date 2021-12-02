function process(commands, functions)
	for i,v in ipairs(commands) do
		functions[v[1]](v[2])
	end
end

function part1(commands)

	local depth, position = 0, 0

	process(commands, {
		forward = function(x) position = position + x end,
		down = function(x) depth = depth + x end,
		up = function(x) depth = depth - x end
	})

	return depth * position
end

function part2(commands)

	local depth, position, aim = 0, 0, 0

	process(commands, {
		forward = function(x)
			position = position + x
			depth = depth + aim * x
		end,
		down = function(x) aim = aim + x end,
		up = function(x) aim = aim - x end
	})

	return depth * position
end

local commands = {}
for line in io.lines "day02.txt" do
	local action,amount = line:match "(%w+) (%d+)"
	table.insert(commands, {action, tonumber(amount)})
end

print("Part 1", part1(commands))
print("Part 2", part2(commands))
