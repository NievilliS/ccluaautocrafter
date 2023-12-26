--[[
* Autocrafting Setup Version 1.0
* Created by Nievillis on Github, Discord and YouTube
* The contents are free to be modified and used with no warranty.
* Content and testing files are openly available at https://github.com/NievilliS/ccluaautocrafter.git
--]]

local _fetch1 = http.get("https://raw.githubusercontent.com/NievilliS/ccluaautocrafter/main/ac_prog.lua")
local _str_dat1 = _fetch1.readAll()
_fetch1.close()

local _fetch2 = http.get("https://raw.githubusercontent.com/NievilliS/ccluaautocrafter/main/setup_ac.lua")
local _str_dat2 = _fetch2.readAll()
_fetch2.close()

if not _str_dat1 or _str_dat1:len() < 10 or not _str_dat2 or _str_dat2:len() < 10 then
    error"Something went wrong whilst trying to get the files."
end
print("Data received!")
print([[
* Autocrafting Setup Version 1.0
* Created by Nievillis on Github, Discord and YouTube
* The contents are free to be modified and used with no warranty.
* Content and testing files are openly available at https://github.com/NievilliS/ccluaautocrafter.git

Continuing in 3 seconds...
]])
sleep(3)

local _f_path1 = "ac_prog"
while fs.exists(_f_path1 .. ".lua") do
	_f_path1 = "ac_prog_(" .. tostring(1 + (tonumber((_f_path1:match "[0-9]+") or "0"))) .. ")"
end
_f_path1 = _f_path1 .. ".lua"

local _f_path2 = "setup_ac"
while fs.exists(_f_path2 .. ".lua") do
	_f_path2 = "setup_ac_(" .. tostring(1 + (tonumber((_f_path2:match "[0-9]+") or "0"))) .. ")"
end
_f_path2 = _f_path2 .. ".lua"

print("Saving 1/2 as " .. _f_path1)
local _file1 = fs.open(_f_path1, "w")
_file1.write(_str_dat1)
_file1.close()
print("Done! 1/2")

print("Saving 2/2 as " .. _f_path2)
local _file2 = fs.open(_f_path2, "w")
_file2.write(_str_dat2)
_file2.close()
print("Done! 2/2")
