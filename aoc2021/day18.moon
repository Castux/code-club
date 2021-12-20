flatten = (node) ->
	flat = {}
	rec = (n) ->
		if type(n) == "number"
			table.insert flat, n
		else
			table.insert flat, '{'
			for i = 1,2 do rec n[i]
			table.insert flat, '}'
	rec node
	flat

numbers = for line in io.lines "day18.txt"
	n = load("return " .. line\gsub('%[', '{')\gsub('%]', '}'))!
	flatten n

explode = (number) ->
	depth = 0
	found = i
	for i,v in ipairs number
		if v == '{' then depth += 1
		elseif v == '}' then depth -= 1
		elseif depth == 5
			found = i
			break
	if not found
		return false
	for i = found-1,1,-1
		if type(number[i]) == "number"
			number[i] += number[found]
			break
	for i = found+2, #number
		if type(number[i]) == "number"
			number[i] += number[found + 1]
			break
	for i = 1,4
		table.remove number, found-1
	table.insert number, found-1, 0
	true

split = (number) ->
	found_index = nil
	found_value = nil
	for i,v in ipairs number
		if type(v) == "number" and v >= 10
			found_index = i
			found_value = v
			break
	if not found_index
		return false
	table.remove number, found_index
	table.insert number, found_index, '{'
	table.insert number, found_index + 1, math.floor(found_value / 2)
	table.insert number, found_index + 2, math.ceil(found_value / 2)
	table.insert number, found_index + 3, '}'
	true

add = (a,b) ->
	sum = {'{'}
	for v in *a do table.insert sum, v
	for v in *b do table.insert sum, v
	table.insert sum, '}'
	while explode(sum) or split(sum)
		nothing
	sum

magnitude = (number) ->
	stack = {}
	for v in *number
		if type(v) == "number" then table.insert stack, v
		elseif v == '}'
			right = table.remove stack
			left = table.remove stack
			table.insert stack, 3 * left + 2 * right
	assert #stack == 1
	stack[1]

part1 = () ->
	tmp = numbers[1]
	for i = 2,#numbers
		tmp = add tmp, numbers[i]
	print "Part 1", magnitude tmp

part2 = () ->
	max = 0
	for v in *numbers do for w in *numbers
		max = math.max max, magnitude(add v, w)
	print "Part 2", max

part1!
part2!
