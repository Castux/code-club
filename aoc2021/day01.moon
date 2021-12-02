count_increases = (data, window = 1) ->
    count = 0
    for i = window + 1, #data
        if data[i] > data[i - window] then count += 1
    count

data = [tonumber(line) for line in io.lines "day01.txt"]

print "Part 1", count_increases data
print "Part 2", count_increases(data, 3)
