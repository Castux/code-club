bits_to_int = (bits) ->
	result = 0
	for i = 1,#bits
		result |= bits[i] << (#bits - i)
	result

most_common_at = (values, rank) ->
	counts = {[0]: 0, [1]: 0}
	for value in *values
		counts[value[rank]] += 1
	if counts[1] >= counts[0] then 1 else 0

filter = (values, most) ->
	rank = 1
	while #values > 1
		model = most_common_at(values, rank)
		if not most then model = 1 - model
		values = [value for value in *values when value[rank] == model]
		rank += 1
	values[1]

data = for line in io.lines "day03.txt"
	for i = 1,#line
		tonumber line\sub(i,i)

part1 = ->
	gamma = bits_to_int [most_common_at(data, i) for i = 1,#data[1]]
	epsilon = ~gamma & ((1 << #data[1]) - 1)
	print "Part 1", gamma * epsilon

part2 = ->
	oxygen = bits_to_int filter(data, true)
	co2 = bits_to_int filter(data, false)
	print "Part 2", oxygen * co2

part1!
part2!
