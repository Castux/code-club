data = [tonumber(line) for line in io.lines "day01.txt"]

count_increases = (window) ->
	#[1 for i = window + 1, #data when data[i] > data[i - window]]

print "Part 1", count_increases 1
print "Part 2", count_increases 3
