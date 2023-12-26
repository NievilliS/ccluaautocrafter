--[[
* Autocrafting Setup Version 1.0
* Created by Nievillis on Github, Discord and YouTube
* The contents are free to be modified and used with no warranty.
* Content and testing files are openly available at https://github.com/NievilliS
--]]

--!! Require cfg_api
if not generic_get_config_table then
	if not fs.exists("cfg_api.lua") then
		printError("Require cfg_api (http://pastebin.com/kQ4VTK32)\nInstall? y/n")
		sleep()
		local e,k = os.pullEvent"key_up"
		while k ~= keys.y and k ~= keys.n do
			e,k = os.pullEvent"key_up"
		end
		
		if k == keys.y then
			shell.run"pastebin run kQ4VTK32"
			
			if not fs.exists("cfg_api.lua") then
				error("\nAn issue occured and the program could not be downloaded. Pastebin API invalid? Please try to download the installer manually at:\nhttps://raw.githubusercontent.com/NievilliS/ccluaconfigapi/main/ccluaconfigapi_install.lua\n\nSorry for the inconvenience!", 0)
			end
			
			shell.run"cfg_api.lua"
			
			if not generic_get_config_table then
				error("\nAn issue occured and no functions were set within cfg_api.lua. Wrong file? Please check if cfg_api.lua is empty! If it is, then the pastebin API key might be invalid. Try to download the installer manually at:\nhttps://raw.githubusercontent.com/NievilliS/ccluaconfigapi/main/ccluaconfigapi_install.lua\n\nSorry for the inconvenience!", 0)
			end
			
			print("\nSuccess! Will proceed program.")
		else
			error("\nCannot continue without cfg_api. The pastebin ID for the installer is kQ4VTK32 and contents are openly available on my repo at:\nhttps://github.com/NievilliS/ccluaconfigapi.git", 0)
		end
	end
	
	shell.run"cfg_api.lua"
			
	if not generic_get_config_table then
		error("\nAn issue occured and no functions were set within cfg_api.lua. Wrong file?", 0)
	end
	
	sleep()
end

term.setTextColor(colors.lightBlue)
print "Autocraft Setup 1.0"
term.setTextColor(colors.white)

local args = {...}
local _path = args[1]

if not _path then
	print "Please input the configuration file."
	term.write("> ")
	_path = io.read()
end

if not fs.exists(_path) then
	error("Path \"" .. _path .. "\" does not exist!", 0)
end

--! Read data
local _raw_dat = generic_get_config_table(_path)

local _btm = peripheral.wrap "bottom"
local _bck = peripheral.wrap "back"

--!! Function creates a deep copy of another table, including multiple references to equal table instances. (Note: Functions cannot be deep-copied.)
_G.deep_copy_table = _G.deep_copy_table or function(_t)
	local _rt = {} --< Returning table
	
	--!! Each original table and its copy share the same index within _recursive_queue and _rt_queue respectively
	local _recursive_queue = {_t} --<! Original Table Queue
	local _new_queue = {}
	local _rt_queue = {_rt} --<! Copy Table Queue
	local _new_rt_queue = {}
	
	--!! This is required to guarantee that multiple instances pointing to the same references is supported. Otherwise you might run into an issue with infinite recursion
	local _table_link = {{original = _t, copy = _rt}, }
	local function __lookup_table_reference_link(_original_table)
		for index, tbls in ipairs(_table_link) do
			if tbls.original == _original_table then
				return index
			end
		end
		return nil
	end
	
	while #_recursive_queue > 0 do
		for i, t in pairs(_recursive_queue) do
			for key, value in pairs(t) do
				--!! Tables (and functions) are the only datatype that require special treatment in Lua
				if type(value) == "table" then
					local _tref_index = __lookup_table_reference_link(value)
					
					--!! In the case that no such table exists within the reference linking table, create a new table and add it to the queue, as well as adding the references to the linking table
					if not _tref_index then
						_rt_queue[i][key] = {}
						setmetatable(_rt_queue[i][key], getmetatable(value))
						_new_rt_queue[#_new_rt_queue + 1] = _rt_queue[i][key]
						_new_queue[#_new_queue + 1] = value
						_table_link[#_table_link + 1] = {original = value, copy = _rt_queue[i][key]}
					--!! In the case that such a table does already exist, fetch the .copy table and set _rt_queue[i][key] to the same reference value. No queueing is required, as the table is already being processed!
					else
						_rt_queue[i][key] = _table_link[_tref_index].copy
					end
				--!! Any other datatype can be freely copied without having to worry about copying references
				else
					_rt_queue[i][key] = value
				end
			end
		end
		
		_recursive_queue = _new_queue
		_new_queue = {}
		_rt_queue = _new_rt_queue
		_new_rt_queue = {}
	end
	
	return _rt
end

--!! Function turns the bottom container contents into a combined item counting map
_G.__get_item_list = _G.__get_item_list or function(_chest)
	local _r_list = _chest.list()
	
	--!! Auxillary tables for items
	local _aux_r = {}
	local _aux_n = {}
	local _aux_s = {r = {}, n = {}}
	
	for slot, item in pairs(_r_list) do
		if item.nbt then
			_aux_n[#_aux_n + 1] = item
			_aux_s.n[#_aux_n] = slot
		else
			_aux_r[item.name] = (_aux_r[item.name] == nil) and item.count or (_aux_r[item.name] + item.count)
			if not _aux_s.r[item.name] then
				_aux_s.r[item.name] = {}
			end
			_aux_s.r[item.name][#(_aux_s.r[item.name]) + 1] = {slot = slot, count = item.count}
		end
	end
	
	local _return_tbl = {}
	
	for name, count in pairs(_aux_r) do
		_return_tbl[#_return_tbl + 1] = {name = name, count = count, slot = _aux_s.r[name]}
	end
	
	for i, t in pairs(_aux_n) do
		_return_tbl[#_return_tbl + 1] = t
		t.slot = _aux_s.n[i]
	end
	
	return _return_tbl
end

--!! Process _raw_dat
local _ac_dat = {}

for _target_name, _dt1 in pairs(_raw_dat) do
	_ac_dat[_target_name] = {result = _dt1._result}
	
	for _item, _dt2 in pairs(_dt1) do
		local _idx = _item:match "^item(%d+)$"
		if _idx then
			_ac_dat[_target_name][tonumber(_idx)] = _dt2
		end
	end
end
_raw_dat = nil

--!! Function that checks if the contents of _inv are enough to satisfy _req
_G.__satisfied_inventory = _G.__satisfied_inventory or function(_req, _inv)
	for _, _t in ipairs(_req) do
		local satisfied = false
		
		for __, _u in ipairs(_inv) do
			if _t.nbt then
				if _u.nbt and _t.nbt == _u.nbt and _t.name == _u.name and _u.count >= _t.count then
					satisfied = true
					break
				end
			else	
				if _t.name == _u.name and _u.count >= _t.count then
					satisfied = true
					break
				end
			end
		end
		
		if not satisfied then
			return false
		end
	end
	return true
end

--!! Function that selects the inventory slots of a desired amount of items
_G.__get_slots_for_item = _G.__get_slots_for_item or function(_inv, _item)
	
	local _count_deficit = _item.count
	local _slot_return = {}
	
	if _item.nbt then
		for _, _t in ipairs(_inv) do
			if _count_deficit <= 0 then
				break
			end
			
			if _t.nbt and _item.nbt == _t.nbt and _item.name == _t.name then
				local _ct = math.min(_count_deficit, _t.count)
				_slot_return[#_slot_return + 1] = {slot = _t.slot, count = _ct}
				_count_deficit = _count_deficit - _ct
			end
		end
		
	--!! Without NBT, all items are put inside the same entry
	else
		for _, _t in ipairs(_inv) do
			if _item.name == _t.name then
				for __, _tsl in ipairs(_t.slot) do
					local _ct = math.min(_count_deficit, _tsl.count)
					_slot_return[#_slot_return + 1] = {slot = _tsl.slot, count = _ct}
					_count_deficit = _count_deficit - _ct
					
					if _count_deficit <= 0 then
						break
					end
				end
				
				--! Wastes less cycles here with the same functionality
				if _count_deficit <= 0 then
					break
				end
			end
		end
	end
	
	return _slot_return
end

--!! Plural version of the above
_G.__get_slots_for_items = _G.__get_slots_for_items or function(_inv, _items) 
	local _slot_return = {}
	for i, _item in ipairs(_items) do
		_slot_return[i] = __get_slots_for_item(_inv, _item)
	end
	return _slot_return
end

--!! STATUS
local _inventory_btm
local _finish_process_name = "Master Crafting"

--!! CHECKER LOOP
while true do
	_inventory_btm = __get_item_list(_btm)
	
	while #_inventory_btm <= 0 do
		sleep(10)
		_inventory_btm = __get_item_list(_btm)
	end
	
	for _dpy_name, _proc in pairs(_ac_dat) do
		--!! If this has been met, then take care of moving all items to where they need to be
		if __satisfied_inventory(_proc, _inventory_btm) then
			local slt_mv_btm_up = __get_slots_for_items(_inventory_btm, _proc)
			local slt_mv_bck_rg = __get_slots_for_item(__get_item_list(_bck), _proc.result)
			
			for _, _data1 in ipairs(slt_mv_btm_up) do
				for __, _data in ipairs(_data1) do
					if _finish_process_name == _dpy_name then
						_btm.pushItems("back", _data.slot, _data.count)
					else
						_btm.pushItems("top", _data.slot, _data.count)
					end
				end
			end
			for _, _data in ipairs(slt_mv_bck_rg) do
				_bck.pushItems("right", _data.slot, _data.count)
			end
			
			print(_dpy_name .. " Process finished")
		end
	end
end
