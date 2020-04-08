local anagrams = require "anagrams"
local js = require "js"
local serialize = require "serialize"

local ui_div
local loading_div
local phrase_input
local results_div
local wordbox_model
local includes_div
local excludes_div
local includes_input
local length_input
local body
local resultbox_model

local dict
local current_search
local start_time

local lang_opt
local diac_opt
local collapse_opt

local worker

local function postMessage(command, argument)

	local obj = js.new(js.global.Object)
	obj.command = command
	obj.arg = serialize.serialize(argument)

	worker:postMessage(obj)
end

local function load_dict()

	ui_div.style.display = "none"
	loading_div.style.display = "block"

	local path = "./" .. lang_opt .. ".txt"

	-- Ask the worker to load the dictionary

	local args =
	{
		ignore_diacritics = diac_opt,
		collapse = collapse_opt,
		path = path
	}

	postMessage("load_dict", args)
end


local function clearResults()

	while results_div.firstChild ~= js.null do
		results_div:removeChild(results_div.firstChild)
	end

end

local add_include, add_exclude

local function create_result_word(str)

	local elem = resultbox_model:cloneNode(true)

	elem.children[0].innerHTML = str

	elem.children[1].onclick = function()
		add_include(str)
	end

	elem.children[2].onclick = function()
		add_exclude(str)
	end

	return elem
end

local function add_result(t)

	local div = js.global.document:createElement "div"
	div.classList:add "resultline"

	for i,v in ipairs(t) do
		for j,w in ipairs(v) do

			local elem = create_result_word(w)
			div:appendChild(elem)

			if j < #v then
				div:appendChild(js.global.document:createTextNode("/"))
			end
		end

		if i < #t then
			div:appendChild(js.global.document:createTextNode(" "))
		end
	end

	results_div:appendChild(div)
end

local function restart_search()

	clearResults()
	body.classList:remove "loading"

	local phrase = phrase_input.value

	local includes = {}

	for i = 0, includes_div.children.length - 1 do
		table.insert(includes, includes_div.children[i].children[0].innerHTML)
	end

	local excludes = {}

	for i = 0, excludes_div.children.length - 1 do
		table.insert(excludes, excludes_div.children[i].children[0].innerHTML)
	end

	local min_len = tonumber(length_input.value)

	local config =
	{
		phrase = phrase,
		includes = includes,
		excludes = excludes,
		min_len = min_len or 1,
		ignore_diacritics = diac_opt,
		collapse = collapse_opt,
		yield_often = true
	}

	postMessage('search', config)

	body.classList:add "loading"
	start_time = os.time()
end

add_include = function(str)

	local elem = wordbox_model:cloneNode(true)

	-- text
	elem.children[0].innerHTML = str

	-- hide dot
	elem.children[1].onclick = function()
		includes_div:removeChild(elem)
		restart_search()
	end

	-- exclude dot
	elem.children[3].onclick = function()
		includes_div:removeChild(elem)
		add_exclude(str)
	end

	-- include dot
	elem:removeChild(elem.children[2])

	elem.classList:add "include"

	includes_div:appendChild(elem)

	restart_search()
end

add_exclude = function(str)

	local elem = wordbox_model:cloneNode(true)

	-- text
	elem.children[0].innerHTML = str

	-- hide dot
	elem.children[1].onclick = function()
		excludes_div:removeChild(elem)
		restart_search()
	end

	-- include dot
	elem.children[2].onclick = function()
		excludes_div:removeChild(elem)
		add_include(str)
	end

	-- exclude dot
	elem:removeChild(elem.children[3])

	elem.classList:add "exclude"

	excludes_div:appendChild(elem)

	restart_search()
end

local function on_includes_input()

	local word = includes_input.value
	includes_input.value = ""

	if word ~= "" then
		add_include(word)
	end
end

local function on_excludes_input()

	local word = excludes_input.value
	excludes_input.value = ""

	if word ~= "" then
		add_exclude(word)
	end
end

local function toggle_collapse_param()

	local params = js.new(js.global.URLSearchParams, js.global.document.location.search)

	local current = params:get("collapse")

	if current == "true" then
		params:set("collapse", "false")
	else
		params:set("collapse", "true")
	end

	js.global.window.location.search = params:toString()

end

local function setup()

	loading_div = js.global.document:getElementById "loading"
	ui_div = js.global.document:getElementById "ui"
	phrase_input = js.global.document:getElementById "phrase_input"
	results_div = js.global.document:getElementById "results"
	includes_div = js.global.document:getElementById "includes"
	excludes_div = js.global.document:getElementById "excludes"
	includes_input = js.global.document:getElementById "includes_input"
	excludes_input = js.global.document:getElementById "excludes_input"
	length_input = js.global.document:getElementById "length_input"
	body = js.global.document:getElementsByTagName("body")[0]

	wordbox_model = includes_div.firstElementChild
	includes_div:removeChild(wordbox_model)

	resultbox_model = results_div.firstElementChild
	results_div:removeChild(resultbox_model)

	phrase_input.onchange = restart_search
	includes_input.onchange = on_includes_input
	excludes_input.onchange = on_excludes_input
	length_input.onchange = restart_search

	-- Collapse button

	local collapse_text = js.global.document:getElementById "collapse"
	collapse_text.onclick = toggle_collapse_param

	-- URL options

	local url_str = js.global.document.location
	local url = js.new(js.global.URL, url_str)
	local lang = url.searchParams:get("lang")
	local diac = url.searchParams:get("diac")
	local collapse = url.searchParams:get("collapse")

	lang_opt = lang ~= js.null and lang or "en"
	diac_opt = diac == "true"
	collapse_opt = collapse == "true"
end

local messages =
{
	dict_loading = function(progress)
		loading_div.innerHTML = string.format("Loading dictionary... %d%%", math.ceil(progress * 100))
	end,

	dict_loaded = function()
		loading_div.style.display = "none"
		ui_div.style.display = "block"
	end,

	invalid = function()
		add_result {{"(invalid includes)"}}
		body.classList:remove "loading"
	end,

	done = function()
		add_result {{"(done in " .. (os.time() - start_time) .. " sec.)"}}
		body.classList:remove "loading"
	end,

	result = function(result)
		local t = {}

		for i = 0, includes_div.children.length - 1 do
			table.insert(t, {includes_div.children[i].children[0].innerHTML})
		end

		for _,word in ipairs(result) do
			table.insert(t, word.strings)
		end

		add_result(t)

		postMessage('continue')
	end,

	pause = function()
		postMessage('continue')
	end
}

local function start_worker()

	worker = js.new(js.global.Worker, "lua-worker.js");

	worker:addEventListener('message', function(self, e)
		messages[e.data.command](serialize.deserialize(e.data.arg))
	end)
end

setup()

start_worker()
load_dict()
