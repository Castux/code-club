local total = 0
local ribbon_total = 0

for line in io.lines "day2.txt" do

	local l,w,h = line:match("(%d+)x(%d+)x(%d+)")

	local a,b,c = l*w, w*h, h*l
	local smallest = math.min(a,b,c)

	local surface = 2 * (a+b+c) + smallest
	total = total + surface
	
	local ribbon = math.min(l+w, w+h, h+l) * 2 + (l*w*h)
	ribbon_total = ribbon_total + ribbon
end

print(total, ribbon_total)
