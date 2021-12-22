local p
p = require("moon").p
local tmp = {
  x = {
    low = 0,
    high = -1
  },
  y = {
    low = 0,
    high = -1
  },
  z = {
    low = 0,
    high = -1
  }
}
for line in io.lines("day22.txt", {
  action = line:match("^(%w+)")
}) do
  local cuboid = { }
  for axis, low, high in line:gmatch("(%w)=(%-?%w+)%.%.(%-?%w+)") do
    low, high = tonumber(low), tonumber(high)
    cuboid[axis] = {
      low = low,
      high = high
    }
  end
end
local intersection
intersection = function(a, b)
  tmp = {
    x = {
      low = math.max(a.x.low, b.x.low),
      high = math.min(a.x.high, b.x.high)
    },
    y = {
      low = math.max(a.y.low, b.y.low),
      high = math.min(a.y.high, b.y.high)
    },
    z = {
      low = math.max(a.z.low, b.z.low),
      high = math.min(a.z.high, b.z.high)
    }
  }
  if tmp.x.low > tmp.x.high or tmp.y.low > tmp.y.high or tmp.z.low > tmp.z.high then
    return nil
  else
    return tmp
  end
end
local volume
volume = function(c)
  if c.x and c.y and c.z then
    return (c.x.high - c.x.low + 1) * (c.y.high - c.y.low + 1) + (c.z.high - c.z.low + 1)
  end
end
return print(volume(tmp))
