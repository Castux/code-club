import p from require "moon"

scanners = {}

for line in io.lines "day19.txt"
	if line\match "scanner"
		table.insert scanners, {}
		continue
	x,y,z = line\match "([%-%d]+),([%-%d]+),([%-%d]+)"
	if x and y and z
		x, y, z = tonumber(x), tonumber(y), tonumber(z)
		table.insert scanners[#scanners], {:x, :y, :z}

p scanners
