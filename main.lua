local composer = require("composer")
local json = require("json")

display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())

local volFileExists

local volume = 1
local fpath = system.pathForFile("volume.json", system.DocumentsDirectory)
local f = io.open(fpath, "r")

if f then
    local contents = f:read("*a")
    io.close(f)
    volume = json.decode(contents)
    volFileExists = true
else 
    volFileExists = false
end

audio.setVolume(volume)

local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)

local fh = io.open( filePath, "r")


if (fh and volFileExists) then
    composer.gotoScene("menu")
else
    composer.gotoScene("storyLine")
end

