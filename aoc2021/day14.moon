rules = {}
digraphs = {}
chars = {}

add = (t, k, v = 1) -> t[k] = (t[k] or 0) + v

for line in io.lines "day14.txt"
	pattern, result = line\match "(%w+) %-> (%w)"
	if pattern and result
		rules[pattern] = result
	elseif line != ""
		for i = 1, #line - 1
			add digraphs, line\sub(i, i + 1)
		for c in line\gmatch "%w"
			add chars, c

step = () ->
	tmp = {}
	for digraph, count in pairs digraphs
		if insert = rules[digraph]
			add tmp, digraph\sub(1,1) .. insert, count
			add tmp, insert .. digraph\sub(2,2), count
			add chars, insert, count
		else
			add tmp, digraph, count
	digraphs = tmp

score = () ->
	flat = [v for k,v in pairs chars]
	table.sort flat
	flat[#flat] - flat[1]

for i = 1,40
	step!
	if i == 10 then print "Part 1", score!
	if i == 40 then print "Part 2", score!
