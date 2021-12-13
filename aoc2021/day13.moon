dots = {}
hashed = {}
folds = {}

for line in io.lines "day13.txt"
	x,y = line\match "(%d+),(%d+)"
	if x and y
		table.insert dots, {x: tonumber(x), y: tonumber(y)}
	dir,val = line\match "fold along (%w)=(%d+)"
	if dir and val
		table.insert folds, {:dir, val: tonumber(val)}

apply_fold = (fold) ->
	for dot in *dots
		if dot[fold.dir] > fold.val
			dot[fold.dir] -= 2 * (dot[fold.dir] - fold.val)

	hashed = {}
	for dot in *dots
		hashed[dot.x .. ":" .. dot.y] = dot
	dots = [dot for _,dot in pairs hashed]

print_dots = () ->
	max_x, max_y = 0,0
	for dot in *dots
		max_x, max_y = math.max(max_x, dot.x), math.max(max_y, dot.y)
	for y = 0,max_y
		for x = 0,max_x
			io.write if hashed[x .. ":" .. y] then "#" else " "
		io.write "\n"

for i,fold in ipairs folds
	apply_fold fold
	if i == 1 then
		print "Part 1", #dots
print "Part 2"
print_dots!