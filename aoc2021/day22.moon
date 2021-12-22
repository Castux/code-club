import p from require "moon"

-- range = 50
--
-- instructions = for line in io.lines "day22.txt"
-- 	ins = { action: line\match "^(%w+)" }
-- 	for axis,low,high in line\gmatch "(%w)=(%-?%w+)%.%.(%-?%w+)"
-- 		low, high = tonumber(low), tonumber(high)
-- 		ins[axis] = :low, :high
-- 		if low < -range or high > range
-- 			ins.ignore_part1 = true
-- 	ins
--
-- hash = (x,y,z) -> string.format "%d:%d:%d", x, y, z
--
-- apply = (ins, cubes) ->
-- 	for x = ins.x.low, ins.x.high
-- 		for y = ins.y.low, ins.y.high
-- 			for z = ins.z.low, ins.z.high
-- 				cubes[hash x, y, z] = if ins.action == "on" then true else nil
--
-- apply_all = () ->
-- 	cubes = {}
-- 	for instruction in *instructions
-- 		if not instruction.ignore_part1
-- 			apply instruction, cubes
--
-- 	print "Part 1", #[1 for k,v in pairs cubes]

--apply_all!

load = () ->
	tmp = {x: {low: 0, high: -1}, y: {low: 0, high: -1}, z: {low: 0, high: -1}}
	for line in io.lines "day22.txt"
		action = line\match "^(%w+)"
		cuboid = {}
		for axis,low,high in line\gmatch "(%w)=(%-?%w+)%.%.(%-?%w+)"
			low, high = tonumber(low), tonumber(high)
			cuboid[axis] = :low, :high

		tmp = {action == "on" and "union" or "difference", tmp, cuboid}
	tmp

is_cuboid = (c) -> c.x and c.y and c.z

intersection = (a,b) ->
	tmp =
		x: {low: math.max(a.x.low, b.x.low), high: math.min(a.x.high, b.x.high)},
		y: {low: math.max(a.y.low, b.y.low), high: math.min(a.y.high, b.y.high)},
		z: {low: math.max(a.z.low, b.z.low), high: math.min(a.z.high, b.z.high)},
	if tmp.x.low > tmp.x.high or tmp.y.low > tmp.y.high or tmp.z.low > tmp.z.high
		nil
	else
		tmp

local volume

-- V(A+B) = V(A) + V(B) - V(A inter B)
-- V(A-B) = V(A) - V(A inter B)
-- V((A + B) inter C) = V(A inter C) + V(B inter C) - V(A inter B inter C)
-- V(A - B) inter C) = V(A inter C) - V(A inter B inter C)

volume_intersection = (a,b) ->
	if not is_cuboid b
		p b
		error "Right hand side cannot be operation"

	if is_cuboid a
		volume intersection(a,b)
	elseif a[1] == "union"
		volume {"union", {"intersection", a[2], b}, {"intersection", a[3], b}}
	elseif a[1] == "difference"
		volume {"difference", {"intersection", a[2], b}, a[3]}

volume = (c) ->
	if not c
		0
	elseif is_cuboid c
		(c.x.high - c.x.low + 1) * (c.y.high - c.y.low + 1) + (c.z.high - c.z.low + 1)
	elseif c[1] == "union"
		volume(c[2]) + volume(c[3]) - volume_intersection(c[2], c[3])
	elseif c[1] == "difference"
		volume(c[2]) - volume_intersection(c[2], c[3])
	elseif c[1] == "intersection"
		volume_intersection(c[2], c[3])

print volume load!
