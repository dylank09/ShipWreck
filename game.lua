
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

local peopleSaved = 0
local gameLoopTimer
local peopleSavedText
local died = false
--local highScore = 0

local debrisTable = {}

local backGroup
local boatGroup
local uiGroup

local boat

local function updateText()
  peopleSavedText.text = " " .. peopleSaved
end

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

--might not need this anymore
--local function reset()
  --if(peopleSaved > highScore) then
    --highScore = peopleSaved
--end
--boat.isBodyActive = false
--boat.x = display.contentCenterX
--boat.y = display.contentHeight - 50
--peopleSaved = 0
--transition.to(boat, {alpha=1, time=2000, onComplete = function()
--  boat.isBodyActive = true
    --boat.x = display.contentCenterX
  --died = false
   --end
--  })
--end

local function gameLoop()
  createDebris()

  for i = #debrisTable, 1, -1 do
    local thisDebris = debrisTable[i]

    if ( thisDebris.y > 600) then
      display.remove( thisDebris )
      table.remove( debrisTable, i )
    end
  end
end

local function endGame()
  composer.setVariable("finalPeopleSaved", peopleSaved)
	composer.gotoScene("highscores", {time=800, effect="crossFade"})
end

local function die(event)
  if(event.phase == "began") then
    local obj1 = event.object1
    local obj2 = event.object2

    if((obj1.myName == "boat" and obj2.myName == "debris") or
       (obj1.myName == "debris" and obj2.myName == "boat")) then

      if(died == false) then
        died = true
				--boat.isBodyActive = false
				--boat.alpha = 1
				timer.performWithDelay(0, endGame)
        --timer.performWithDelay(800, reset)
      end
    end
  end
end




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	boatGroup = display.newGroup()
	sceneGroup:insert(boatGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	local background = display.newImageRect(backGroup, "background.jpg", 852, 580)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local boat = display.newImageRect(boatGroup, "rescueboat1.png", 65, 119)
	boat.x = display.contentCenterX
	boat.y = display.contentHeight - 50
	physics.addBody(boat, {isSensor=true})
	boat.myName = "boat"

	peopleSavedText = display.newText(uiGroup, " " .. peopleSaved, 155, 20, native.systemFont, 50)

  boat:addEventListener("touch", moveBoat)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener("collision", die)
		gameLoopTimer = timer.performWithDelay(1500, gameLoop, 0)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel(gameLoopTimer)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener("collision", die)
		physics.pause()
		composer.removeScene("game")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
