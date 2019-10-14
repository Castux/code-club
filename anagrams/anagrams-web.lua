local anagrams = require "anagrams"
local js = require "js"

local ui_div
local loading_div
local phrase_input
local results_div

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

local function setup()
	
	loading_div = js.global.document:getElementById "loading"
	ui_div = js.global.document:getElementById "ui"
	phrase_input = js.global.document:getElementById "phrase_input"
	results_div = js.global.document:getElementById "results"
	
	phrase_input.onchange = on_input
end

setup()

load_dict()
