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

print "Which file should this be saved into?"
term.write("> ")
local _path = io.read()

local _append = false
if fs.exists(_path) then
	print "Append from the start? y/n"
	
	local _e, _k = 0, 0
	
	while _k ~= keys.y and _k ~= keys.n do
		sleep()
		_e, _k = os.pullEvent "key_up"
	end
	
	_append = (_k == keys.y)
end

generic_save_config_table({}, _path, _append, _append and {} or {["."] = "Crafting Config"})
sleep(0.1)

term.setTextColor(colors.lightGray)
print "Please input the master crafting patterns into the bottom container. Slot 1 Shall always be the result and only use up to 9 other slots in total.\ny - Save bottom barrel\nq - Quit\n"
term.setTextColor(colors.white)

--!! Interface loop
local _e, _k = 0, 0
while _k ~= keys.q do
	
	_e, _k = os.pullEvent "key_up"
	sleep()
	
	if _k == keys.y then
		
		--!! Get item details
		local btm = peripheral.wrap "bottom"
		
		local itemdetail = btm.getItemDetail(1)
		if itemdetail then
			local nbt = itemdetail.nbt
			local dpy_name = itemdetail.displayName
			local itemtype = itemdetail.name
			local itemcount = itemdetail.count
			
			local storage = {}
			local nbt_storage = {}
			local slot_pointer = {}
			
			for i,t in pairs(btm.list()) do
				--! Collect the totaling amount of each item
				if i ~= 1 then
					local itd = btm.getItemDetail(i)
					if itd.nbt then
						nbt_storage[#nbt_storage + 1] = {name = itd.name, count = itd.count, nbt = itd.nbt, __dpy_name = itd.displayName}
					else
						storage[t.name] = (storage[t.name] and (storage[t.name] + t.count)) or t.count
						slot_pointer[t.name] = i
					end
				end
			end
			
			local desc = {["." .. dpy_name] = "Process of " .. dpy_name .. ":"}
			
			local cfg_tbl = {}
			cfg_tbl[dpy_name] = {}
			local rt = cfg_tbl[dpy_name]
			
			--! Intert data of to be crafted item into result
			rt._result = {nbt = nbt, count = itemcount, name = itemtype}
			
			--!! Table id assigning
			local counter = 1
			
			--!! Save items as item[n] tables
			for n, c in pairs(storage) do
				local index = "item" .. tostring(counter)
				rt[index] = {name = n, count = c}
				counter = counter + 1
				
				--!! Create comment for any count that is above max stack size
				local stack_ratio = c / btm.getItemDetail(slot_pointer[n]).maxCount
				if stack_ratio > 1.0 then
					local mxc = btm.getItemDetail(slot_pointer[n]).maxCount
					local stc = math.floor(stack_ratio)
					local xtr = math.floor((stack_ratio - stc) * mxc)
					
					desc["." .. dpy_name .. "." .. index .. ".count"] = tostring(stc) .. "s + " .. tostring(xtr) .. " (" .. tostring(mxc) .. " stack size)"
				end
			end
			for _, t in ipairs(nbt_storage) do
				rt["item" .. tostring(counter)] = t
				--! Always create comment, as these entries are mostly for the crafting process 
				desc["." .. dpy_name .. ".item" .. tostring(counter)] = "Display Name of item: " .. t.__dpy_name
				t.__dpy_name = nil
				counter = counter + 1
			end
			
			--! Save into path
			term.setTextColor(colors.yellow)
			print("Saving crafting table of " .. dpy_name .. ". Items:")
			term.setTextColor(colors.orange)
			
			for k, t in pairs(rt) do
				if k:match "^item%d+$" then
					print("  " .. t.name .. ",")
				end
			end
			
			term.setTextColor(colors.white)
			
			generic_save_config_table(cfg_tbl, _path, true, desc)
			
			print "Done, proceed!\n"
			
		else
			printError "No item present in slot 1"
		end
	
	--! Quit Proc
	elseif _k == keys.q then
		term.setTextColor(colors.red)
		print "Confirm: q/any"
		_e, _k = os.pullEvent "key_up"
		sleep(0)
	else
		term.setTextColor(colors.lightGray)
		print "Please input the master crafting patterns into the bottom container. Slot 1 Shall always be the result and only use up to 9 other slots in total.\ny - Save bottom barrel\nq - Quit\n"
		term.setTextColor(colors.white)
	end
end
