local anagrams = require "anagrams"
local js = require "js"

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

local function continue_loading_dict(co, total_count)

	local status,result = coroutine.resume(co)

	if type(result) == "table" then

		dict = result

		loading_div.style.display = "none"
		ui_div.style.display = "block"

	else

		loading_div.innerHTML = "Loading dictionary... " .. math.ceil(result / total_count * 100) .. "%"
		js.global:requestAnimationFrame(function()
			continue_loading_dict(co, total_count)
		end)
	end
end

local function on_dict_loaded(str)

	local words = {}
	for w in str:gmatch "[^\r\n]+" do
		table.insert(words, w)
	end

	local config =
	{
		ignore_diacritics = diac_opt,
		collapse = collapse_opt,
		yield_often = true
	}

	local co = coroutine.create(function()
		return anagrams.load_dict(words, config)
	end)

	continue_loading_dict(co, #words)
end

local function load_dict()

	ui_div.style.display = "none"
	loading_div.style.display = "block"

	-- Load the dictionary

	local path = "./" .. lang_opt .. ".txt"

	local req = js.new(js.global.XMLHttpRequest)
	req:open('GET', path)
	req.onload = function() on_dict_loaded(req.responseText) end
	req:send()

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

local progress_search

progress_search = function()

	if not current_search then
		return
	end

	local result = current_search()
	if not result then
		current_search = nil
		add_result {{"(done in " .. (os.time() - start_time) .. " sec.)"}}

		body.classList:remove "loading"

		return
	end

	if result ~= "pause" then

		local t = {}

		for i = 0, includes_div.children.length - 1 do
			table.insert(t, {includes_div.children[i].children[0].innerHTML})
		end

		for _,word in ipairs(result) do
			table.insert(t, word.strings)
		end

		add_result(t)
	end

	js.global:requestAnimationFrame(progress_search)
end

local function restart_search()

	clearResults()
	current_search = nil
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
		includes = includes,
		excludes = excludes,
		min_len = min_len or 1,
		ignore_diacritics = diac_opt,
		collapse = collapse_opt,
		yield_often = true
	}

	current_search = anagrams.find(dict, phrase, config)

	if not current_search then
		add_result {{"(invalid includes)"}}
		return
	end

	body.classList:add "loading"
	start_time = os.time()

	js.global:requestAnimationFrame(progress_search)
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

setup()

load_dict()
