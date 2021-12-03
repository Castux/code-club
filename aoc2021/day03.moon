bits_to_int = (bits) ->
	result = 0
	for i = 1,#bits
		result |= bits[i] << (#bits - i)
	result

most_common_at = (values, i) ->
	count,total = 0,0
	for value in *values
		total += 1
		count += 1 if value[i] == 1
	if count >= total // 2 then 1 else 0

data = for line in io.lines "day03.txt"
	for i = 1,#line
		tonumber line\sub(i,i)

part1 = ->
	most_common = [most_common_at(data, i) for i = 1,#data[1]]
	least_common = [(v + 1) % 2 for v in *most_common]
		
	gamma = bits_to_int most_common
	epsilon = bits_to_int least_common
	print gamma * epsilon

part1!