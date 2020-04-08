local js = require "js"
local anagrams = require "anagrams"

local ignore_diacritics, collape
local dict

local function continue_loading_dict(co, total_count)

	local status,result = coroutine.resume(co)

	if type(result) == "table" then
		dict = result
        post_message('dict_loaded')
	else
        post_message('dict_loading', result / total_count)
        continue_loading_dict(co, total_count)
	end
end

local function on_dict_loaded(str)

    print("Downloaded dict: " .. #str)

	local words = {}
	for w in str:gmatch "[^\r\n]+" do
		table.insert(words, w)
	end

	local config =
	{
		ignore_diacritics = ignore_diacritics,
		collapse = collapse,
		yield_often = true
	}

	local co = coroutine.create(function()
		return anagrams.load_dict(words, config)
	end)

	continue_loading_dict(co, #words)
end

local messages =
{
    set_ignore_diacritics = function(v)
        ignore_diacritics = v
    end,

    set_collapse = function(v)
        collapse = v
    end,

    load_dict = function(path)

        local req = js.new(js.global.XMLHttpRequest)
        req:open('GET', path)
        req.onload = function() on_dict_loaded(req.responseText) end
        req:send()

    end
}


function on_message(cmd, arg)
    post_message('ack', cmd .. "," ..  arg)
    messages[cmd](arg)
end
