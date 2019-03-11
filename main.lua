-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local backGroup = display.newGroup()
local boatGroup = display.newGroup()
local uiGroup = display.newGroup()

local background = display.newImageRect(backGroup, "background.jpg", 852, 580)
background.x = display.contentCenterX
background.y = display.contentCenterY

local boat = display.newImageRect(boatGroup, "rescueboat1.png", 40, 100)
boat.x = display.contentCenterX
boat.y = display.contentCenterY + 210
