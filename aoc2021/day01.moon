count_increases = (data, window = 1) ->
	#[1 for i = window + 1, #data when data[i] > data[i - window]]

data = [tonumber(line) for line in io.lines "day01.txt"]

print "Part 1", count_increases data
print "Part 2", count_increases(data, 3)
