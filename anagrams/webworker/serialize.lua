local function serialize(t)

	if type(t) == "table" then
		local res = {}
		for k,v in pairs(t) do
			table.insert(res, string.format("[%s]=%s", serialize(k), serialize(v)))
		end

		return "{" .. table.concat(res, ",") .. "}"

	elseif type(t) == "string" then
		return "'".. t .. "'"
	elseif not t or type(t) == "number" or type(t) == "boolean" then
		return tostring(t)
	else
        error("Invalid type to serialize: " .. type(t))
	end
end

local function deserialize(str)

    if str then
        return load("return (" .. str .. ")")()
    else
        return nil
    end
end

return
{
    serialize = serialize,
    deserialize = deserialize
}
