local function serialize(t)

	if type(t) == "table" then
		local res = {}

        for i,v in ipairs(t) do
            table.insert(res, serialize(v))
        end

		for k,v in pairs(t) do
            local is_index =
                type(k) == "number" and
                math.tointeger(k) and
                k >= 1 and
                k <= #t

            if not is_index then
			    table.insert(res,
                    string.format("[%s]=%s", serialize(k), serialize(v))
                )
            end
		end

		return "{" .. table.concat(res, ",") .. "}"

	elseif type(t) == "string" then
		return string.format("%q", t)
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
