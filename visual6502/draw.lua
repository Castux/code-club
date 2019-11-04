local segdefs = require "segdefs"

local layer_colors =
{
	'rgba(128,128,192,0.4)',
	'#FFFF00',
	'#FF00FF',
	'#4DFF4D',
	'#FF4D4D',
	'#801AC0',
	'rgba(128,0,255,0.75)'
}

local function draw_segment(seg, res)

	local tmp = '<polygon points="'

	for i = 4,#seg,2 do
		local x,y = seg[i], -seg[i+1]
		tmp = tmp .. x .. "," .. y .. " "

		if x < res.minx then
			res.minx = x
		end

		if x > res.maxx then
			res.maxx = x
		end

		if y < res.miny then
			res.miny = y
		end

		if y > res.maxy then
			res.maxy = y
		end
	end

	tmp = tmp .. '" />'

	table.insert(res, tmp)
end

local function draw_layer(i, segments, res)

	table.insert(res, string.format('<g fill="%s">', layer_colors[i+1]))

	for _,seg in ipairs(segments) do
		draw_segment(seg, res)
	end

	table.insert(res, "</g>")
end

local function draw()

	local layers = {}

	for i,seg in ipairs(segdefs) do

		local layer = seg[3]
		layers[layer] = layers[layer] or {}

		table.insert(layers[layer], seg)
	end

	local res = {}
	res.minx = math.maxinteger
	res.maxx = math.mininteger
	res.miny = math.maxinteger
	res.maxy = math.mininteger


	for i,layer in pairs(layers) do
		draw_layer(i, layer, res)
	end

	local width = res.maxx - res.minx
	local height = res.maxy - res.miny

	table.insert(res, 1, '<html>')
	table.insert(res, 2, string.format("<svg width='%d' height='%d' viewBox='%d %d %d %d'>",
			width // 10, height // 10,
			res.minx, res.miny, width, height))
	table.insert(res, "</svg>")
	table.insert(res, "</html>")

	local fp = io.open("out.html", "w")
	fp:write(table.concat(res, "\n"))
	fp:close()
end

draw()