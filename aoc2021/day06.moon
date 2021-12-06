counts = {k,0 for k = 0,8}
for n in io.open("day06.txt")\read("a")\gmatch("%d+")
	counts[tonumber n] += 1

iterate = () ->
	zeroes = counts[0]
	for timer = 0,7 do
		counts[timer] = counts[timer + 1]
	counts[8] = zeroes
	counts[6] += zeroes

total = () ->
	sum = 0
	for k,v in pairs counts do sum += v
	sum

for i = 1,256
	iterate!
	if i == 80  then print "Part 1", total counts
	if i == 256 then print "Part 2", total counts
