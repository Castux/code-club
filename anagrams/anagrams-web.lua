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

local dict
local current_search

local function on_dict_loaded(str)

	local words = {}
	for w in str:gmatch "%w+" do
		w = w:lower()
		table.insert(words, w)
	end

	dict = anagrams.load_dict(words)
	
	loading_div.style.display = "none"
	ui_div.style.display = "block"
end

local function load_dict()

	ui_div.style.display = "none"
	loading_div.style.display = "block"

	-- Load the dictionary

	local req = js.new(js.global.XMLHttpRequest)
	req:open('GET', '/dict.txt')
	req.onload = function() on_dict_loaded(req.responseText) end
	req:send()

end

local function clearResults()
	
	while results_div.firstChild ~= js.null do
		results_div:removeChild(results_div.firstChild)
	end
	
end

local function add_result(str)
	
	local div = js.global.document:createElement "div"
	div.innerHTML = str
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
		add_result "(done)"
		return
	end
	
	if result ~= "pause" then
		
		local str = ""
		
		for _,word in ipairs(result) do
			str = str .. word.string .. " "
		end
		
		add_result(str)
	end
	
	js.global:setTimeout(progress_search, 1)
end

local function on_input(str)
	
	clearResults()
	current_search = nil
	
	local phrase = phrase_input.value
	
	current_search = anagrams.find(dict, phrase, {}, {}, 1, "yield_often")
	
	js.global:setTimeout(progress_search, 1)
end

local function add_include(str)
	
	local elem = wordbox_model:cloneNode(true)
	elem.firstElementChild.innerHTML = str
	elem.classList:add "include"
	
	includes_div:appendChild(elem)
	
end

local function add_exclude(str)

	local elem = wordbox_model:cloneNode(true)
	elem.firstElementChild.innerHTML = str
	elem.classList:add "exclude"
	
	excludes_div:appendChild(elem)
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

local function setup()
	
	loading_div = js.global.document:getElementById "loading"
	ui_div = js.global.document:getElementById "ui"
	phrase_input = js.global.document:getElementById "phrase_input"
	results_div = js.global.document:getElementById "results"
	includes_div = js.global.document:getElementById "includes"
	excludes_div = js.global.document:getElementById "excludes"
	includes_input = js.global.document:getElementById "includes_input"
	excludes_input = js.global.document:getElementById "excludes_input"

	wordbox_model = includes_div.firstElementChild
	includes_div:removeChild(wordbox_model)
	
	phrase_input.onchange = on_input
	includes_input.onchange = on_includes_input
	excludes_input.onchange = on_excludes_input
end

setup()

load_dict()
