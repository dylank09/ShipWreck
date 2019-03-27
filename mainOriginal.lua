-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local backGroup = display.newGroup()
local boatGroup = display.newGroup()
local uiGroup = display.newGroup()
display.setStatusBar(display.HiddenStatusBar)

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)
math.randomseed(os.time() )

local peopleSaved = 0
local gameLoopTimer

local debrisTable = {}

local peopleSavedText
local died = false
local highScore = 0

local background = display.newImageRect(backGroup, "background.jpg", 852, 580)
background.x = display.contentCenterX
background.y = display.contentCenterY

local boat = display.newImageRect(boatGroup, "rescueboat1.png", 65, 119)
boat.x = display.contentCenterX
boat.y = display.contentHeight - 50
physics.addBody(boat, {radius=50, isSensor=true})
boat.myName = "boat"

--local debris = display.newImageRect(boatGroup, "debris.png", 70, 70)
--physics.addBody(debris, "dynamic", {radius=35, bounce=0.8})
--debris.myName = "debris"

local function createDebris()
  local newDebris = display.newImageRect(boatGroup, "debris.png", 70,70)
  table.insert(debrisTable, newDebris)
  physics.addBody(newDebris, "dynamic", {radius=35, bounce=0.6})
  newDebris.myName = "debris"

  local xVal = math.random(3)

  if(xVal == 1) then
    newDebris.x = 45
    newDebris.y = math.random(-250, -50)
  elseif(xVal == 2) then
    newDebris.x = 158
    newDebris.y = math.random(-250, -50)
  elseif(xVal == 3) then
    newDebris.x = 270
    newDebris.y = math.random(-250, -50)
  end
  newDebris:setLinearVelocity(0, 200)
  newDebris:applyTorque(math.random(-1, 1))
end

peopleSavedText = display.newText(uiGroup, " " .. peopleSaved, 155, 20, native.systemFont, 50)

local function updateText()
  peopleSavedText.text = " " .. peopleSaved
end

local function moveBoat (event)
  local boat = event.target
  local phase = event.phase

  if("began" == phase) then
    display.currentStage:setFocus(boat)
    boat.touchOffsetX =  event.x - boat.x

  elseif("moved" == phase) then
    boat.x = event.x - boat.touchOffsetX

  elseif("ended" == phase or "cancelled" == phase) then
    display.currentStage:setFocus(nil)
  end

  return true
end

boat:addEventListener("touch", moveBoat)

local function reset()
  if(peopleSaved > highScore) then
    highScore = peopleSaved
  end
  boat.isBodyActive = false
  boat.x = display.contentCenterX
  boat.y = display.contentHeight - 50
  peopleSaved = 0
  transition.to(boat, {alpha=1, time=3000, onComplete = function()
    boat.isBodyActive = true
    --boat.x = display.contentCenterX
    died = false
   end
  })
end

local function gameLoop()
  createDebris()

  for i = #debrisTable, 1, -1 do
    local thisDebris = debrisTable[i]

      if ( thisDebris.x < -100 or
           thisDebris.x > display.contentWidth + 100 or
           thisDebris.y < -100 or
           thisDebris.y > display.contentHeight + 100 )
     then
          display.remove( thisDebris )
          table.remove( debrisTable, i )
    end
  end
end

gameLoopTimer = timer.performWithDelay(1500, gameLoop, 0)

local function die(event)
  if(event.phase == "began") then
    local obj1 = event.object1
    local obj2 = event.object2

    if((obj1.myName == "boat" and obj2.myName == "debris") or
       (obj1.myName == "debris" and obj2.myName == "boat")) then

      if(died == false) then
        died = true
        boat.alpha = 0
        timer.performWithDelay(800, reset)
      end
    end
  end
end

Runtime:addEventListener("collision", die)
