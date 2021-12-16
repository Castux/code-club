bits = {}
for x in io.open("day16.txt")\read("a")\gmatch("%x")
	x = tonumber x, 16
	for i = 3,0,-1
		table.insert bits, (x >> i) & 1

index = 1

get_next = (n) ->
	number = 0
	for i = 1,n
		number <<= 1
		number |= bits[index]
		index += 1
	number

local parse

parse_literal = () ->
	number = 0
	while true
		more = get_next 1
		number <<= 4
		number |= get_next 4
		if more == 0 then break
	number

parse_operator = () ->
	subs = {}
	length_type_id = get_next 1
	if length_type_id == 0
		total_length = get_next 15
		start_index = index
		while index - start_index < total_length
			table.insert subs, parse!
	else
		num_subpackets = get_next 11
		for i = 1,num_subpackets
			table.insert subs, parse!
	subs

parse = () ->
	packet =
		version: get_next 3
		type_id: get_next 3

	if packet.type_id == 4
		packet.value = parse_literal!
	else
		packet.subpackets = parse_operator!
	packet

sum_version = (packet) ->
	sum = packet.version
	if packet.subpackets
		for sub in *packet.subpackets
			sum += sum_version sub
	sum

local compute_value

fold = (packet, op) ->
	tmp = compute_value packet.subpackets[1]
	for i = 2,#packet.subpackets
		tmp = op tmp, compute_value packet.subpackets[i]
	tmp

ops =
	[0]: (a,b) -> a + b
	[1]: (a,b) -> a * b
	[2]: math.min
	[3]: math.max
	[5]: (a,b) -> if a > b then 1 else 0
	[6]: (a,b) -> if a < b then 1 else 0
	[7]: (a,b) -> if a == b then 1 else 0

compute_value = (packet) ->
	if packet.type_id == 4
		packet.value
	else
		fold packet, ops[packet.type_id]

packet = parse!
print "Part 1", sum_version packet
print "Part 2", compute_value packet
