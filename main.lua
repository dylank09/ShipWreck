local composer = require("composer")
local json = require("json")

display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())

local volume
local fpath = system.pathForFile("volume.json", system.DocumentsDirectory)
local f = io.open(fpath, "r")

if f then
    local contents = f:read("*a")
    io.close(f)
    volume = json.decode(contents)
end

if (volume == nil or volume == 0) then
    audio.setVolume(0)

else
    audio.setVolume(1)
end


local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)

local fh = io.open( filePath, "r")

if (fh) then
    composer.gotoScene("menu")
else
    composer.gotoScene("storyLine")
end

