local bf = require "bf"

local src = {}

local current_pointer = 0

function emit(s)
	table.insert(src, s)
end

function dump()
	return table.concat(src)
end

function move_pointer(dest)
	
	local delta = dest - current_pointer
	
	if delta > 0 then
		emit(string.rep(">", delta))
	elseif delta < 0 then
		emit(string.rep("<", -delta))
	end
	
	current_pointer = dest
end

function const(value, index)
	move_pointer(index)
	emit "[-]"
	emit(string.rep("+", value))
end

function add(a,b)
	move_pointer(b)
	emit "[-"
	move_pointer(a)
	emit "+"
	move_pointer(b)
	emit "]"
end

function Block(vars, ops)
	return
	{
		type = "block",
		vars = vars,
		ops = ops
	}
end

function Set(var, value)
	return
	{
		type = "set",
		var = var,
		value = value
	}
end

function Add(a,b,c)
	
	Times
	
end

Block({"a","b","c"},
{
	Set("a", 5),
	Set("b", 10),
	Add("a","b","c")
})

bf.run(dump())