local composer = require("composer")
display.setStatusBar(display.HiddenStatusBar)
math.randomseed(os.time())
audio.setVolume(1, {channel=1})

local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)

local fh = io.open( filePath, "r")

if (fh) then
    composer.gotoScene("menu")
else
    composer.gotoScene("storyLine")
end

