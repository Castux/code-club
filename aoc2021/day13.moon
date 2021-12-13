dots = {}
folds = {}
hash = (dot) -> dot.x .. ":" .. dot.y

for line in io.lines "day13.txt"
	x, y = line\match "(%d+),(%d+)"
	if x and y
		dot = {x: tonumber(x), y: tonumber(y)}
		dots[hash(dot)] = dot
	dir, val = line\match "fold along (%w)=(%d+)"
	if dir and val
		table.insert folds, {:dir, val: tonumber(val)}

apply_fold = (fold) ->
	tmp = {}
	for _, dot in pairs dots
		if dot[fold.dir] > fold.val
			dot[fold.dir] -= 2 * (dot[fold.dir] - fold.val)
		tmp[hash(dot)] = dot
	dots = tmp

print_dots = () ->
	max_x, max_y = 0,0
	for _, dot in pairs dots
		max_x, max_y = math.max(max_x, dot.x), math.max(max_y, dot.y)
	for y = 0, max_y
		for x = 0, max_x
			io.write if dots[hash :x, :y] then "#" else " "
		io.write "\n"

for i, fold in ipairs folds
	apply_fold fold
	if i == 1 then
		print "Part 1", #[1 for k,v in pairs dots]
print "Part 2"
print_dots!
