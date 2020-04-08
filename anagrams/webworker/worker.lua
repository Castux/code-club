local js = require "js"
local anagrams = require "anagrams"
local serialize = require "serialize"

local dict

local function postMessage(cmd, arg)
    post_message_internal(cmd, serialize.serialize(arg))
end

local function continue_loading_dict(co, total_count)

	local status,result = coroutine.resume(co)

	if type(result) == "table" then
		dict = result
        postMessage('dict_loaded')
	else
        postMessage('dict_loading', result / total_count)
        continue_loading_dict(co, total_count)
	end
end

local function on_dict_loaded(str, args)

    print("Downloaded dict: " .. #str)

	local words = {}
	for w in str:gmatch "[^\r\n]+" do
		table.insert(words, w)
	end

	local config =
	{
		ignore_diacritics = args.ignore_diacritics,
		collapse = args.collapse,
		yield_often = true
	}

	local co = coroutine.create(function()
		return anagrams.load_dict(words, config)
	end)

	continue_loading_dict(co, #words)
end

local function progress_search(search)

    local result = search()

    if not result then
        postMessage('done')
        return
    end

    if result ~= "pause" then
        postMessage('result', result)
    end

    progress_search(search)
end

local messages =
{
    load_dict = function(args)

        local req = js.new(js.global.XMLHttpRequest)
        req:open('GET', args.path)
        req.onload = function() on_dict_loaded(req.responseText, args) end
        req:send()
    end,

    search = function(config)

        local search = anagrams.find(dict, config.phrase, config)

        if not search then
            postMessage('invalid')
            return
        end

        progress_search(search)
    end
}

function on_message(cmd, arg)
    messages[cmd](serialize.deserialize(arg))
end
