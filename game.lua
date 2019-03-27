
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

local middle = 160
local menuButton
local boatx
local touchx
local peopleSaved = 0
local gameLoopTimer
local peopleSavedText
local died = false
--local highScore = 0



local backg1
local backg2
local backg3


local debrisTable = {}
local peopleTable = {}

_W = display.contentWidth -- Get the width of the screen
_H = display.contentHeight -- Get the height of the screen
scrollSpeed = 3.4 -- Set Scroll Speed of background

local backGroup
local boatGroup
local uiGroup

local musicTrack

local boat

local function updateText()
  peopleSavedText.text = " " .. peopleSaved
end

local function createDebris()
  local newDebris = display.newImageRect(boatGroup, "debris.png", 80,80)
	table.insert(debrisTable, newDebris)
  physics.addBody(newDebris, "dynamic", {radius=34, bounce=0.8})
  newDebris.myName = "debris"
  newDebris.alpha = 0.71

  local xVal = math.random(3)

  if(xVal == 1) then
    newDebris.x = 60
    newDebris.y = math.random(-250, -50)
  elseif(xVal == 2) then
    newDebris.x = 160
    newDebris.y = math.random(-250, -50)
  elseif(xVal == 3) then
    newDebris.x = 260
    newDebris.y = math.random(-250, -50)
  end
  newDebris:setLinearVelocity(0, 200)
  newDebris:applyTorque(math.random(-1, 1))
end

local function createPerson()
  local newPerson = display.newImageRect(boatGroup, "person.png", 50,70)
	table.insert(peopleTable, newPerson)
  physics.addBody(newPerson, "dynamic", {radius=34, bounce=0.6})
  newPerson.myName = "person"
  newPerson.alpha = 0.9

  local xVal = math.random(3)

  if(xVal == 1) then
    newPerson.x = 60
    newPerson.y = math.random(-400, -50)
  elseif(xVal == 2) then
    newPerson.x = 160
    newPerson.y = math.random(-400, -50)
  elseif(xVal == 3) then
    newPerson.x = 260
    newPerson.y = math.random(-400, -50)
  end
  newPerson:setLinearVelocity(0, 195)

end

local function moveBoat (event)
  local boat = event.target
  local phase = event.phase

  if("began" == phase) then
    display.currentStage:setFocus(boat)
    boat.touchOffsetX =  event.x - boat.x

  elseif("moved" == phase) then

    --if ((boat.x > 150 and boat.x < 170) or (boat.x < 120) or (boat.x > 250)) then
      --transition.to( boat, { rotation=0, time=0,} ) --transition=easing.inOutCubic } )
    --elseif(boat.x < 150) then
      --transition.to( boat, { rotation=-15, time=0} ) --transition=easing.inOutCubic } )
    --elseif (boat.x > 170) then
      --transition.to( boat, { rotation=15, time=0} ) --transition=easing.inOutCubic } )
    --end

    --boat.x = event.x - boat.touchOffsetX

    if (event.x < boat.x and boat.x == 260) then
      transition.to( boat, { time=200, x=160, transition=easing.inOutCirc } )
    elseif(event.x > boat.x and boat.x == 60) then
      transition.to( boat, { time=200, x=160, transition=easing.inOutCirc } )
    elseif(event.x < boat.x and boat.x == 160) then
      transition.to( boat, { time=200, x=60, transition=easing.inOutCirc } )
    elseif(event.x > boat.x and boat.x == 160) then
      transition.to( boat, { time=200, x=260, transition=easing.inOutCirc } )
    end

  elseif("ended" == phase or "cancelled" == phase) then
    --transition.to( boat, { rotation=0, time=0} )
    display.currentStage:setFocus(nil)
  end

  return true
end

--*****might not need this anymore*********
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

local function printer()
  print("Boat moving...")
end

local function gameLoop()
  createDebris()
  createPerson()

  for i = #debrisTable, 1, -1 do
    local thisDebris = debrisTable[i]

    if ( thisDebris.y > 600) then
      display.remove( thisDebris )
      table.remove( debrisTable, i )
    end
  end

--  for i = #peopleTable, 1, -1 do
--    local thisPerson = peopleTable[i]

--    if ( thisPerson.y > 1000 ) then
--      display.remove( thisPerson )
--      table.remove( peopleTable, i )
--    end
--  end
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
       (obj1.myName == "debris" and obj2.myName == "boat") and
       (died == false)) then
         died = true
			   timer.performWithDelay(0, endGame)
    end

    if((obj1.myName == "boat" and obj2.myName == "person") or
       (obj1.myName == "person" and obj2.myName == "boat") and
       (died == false)) then
        peopleSaved = peopleSaved + 1
        updateText()
        display.remove(obj2)
    end
  end
end

local function moveBackground(event)

  -- move backgrounds to the left by scrollSpeed, default is 8
  backg1.y = backg1.y + scrollSpeed
  backg2.y = backg2.y + scrollSpeed
  backg3.y = backg3.y + scrollSpeed

  --create listeners for when backgrounds hit a certain point off screen
  --move the background to the right when gone
  if (backg1.y + backg1.contentWidth) > 1300 then
    backg1:translate( 0, -480*3 )
  end
  if (backg2.y + backg2.contentWidth) > 1300 then
    backg2:translate( 0, -480*3 )
  end
  if (backg3.y + backg3.contentWidth) > 1300 then
    backg3:translate( 0, -480*3 )
  end

  local function gotoMenu()
  	composer.gotoScene("menu", {time=800, effect="crossFade"})
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

  -- Add First Background
  backg1 = display.newImageRect(backGroup, "1.jpg", 320, 480)
  --bg1:setReferencePoint(display.CenterLeftReferencePoint)
  backg1.x = display.contentCenterX
  backg1.y = _H/2

  -- Add Second Background
  backg2 = display.newImageRect(backGroup, "1.jpg", 320, 480)
  --bg2:setReferencePoint(display.CenterLeftReferencePoint)
  backg2.x = display.contentCenterX
  backg2.y = backg1.y+480

  -- Add Third Background
  backg3 = display.newImageRect(backGroup, "1.jpg", 320, 480)
  --bg3:setReferencePoint(display.CenterLeftReferencePoint)
  backg3.x = display.contentCenterX
  backg3.y = backg2.y+480

	--local background = display.newImageRect(backGroup, "curvy.png", 852, 580)
	--background.x = display.contentCenterX
	--background.y = display.contentCenterY

	local boat = display.newImageRect(boatGroup, "boatWwaves.png", 95, 124)
	boat.x = display.contentCenterX
	boat.y = display.contentHeight - 50
	physics.addBody(boat, {isSensor=true})
	boat.myName = "boat"

	peopleSavedText = display.newText(uiGroup, " " .. peopleSaved, 155, 20, "ARCADECLASSIC.TTF", 50)

  boat:addEventListener("touch", moveBoat)

  musicTrack = audio.loadStream("gameSong.mp3")

  menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX+110, 0, "ARCADECLASSIC.TTF", 25)
  menuButton:setFillColor(1, 0.3, 0.2)
  menuButton:addEventListener("tap", endGame)

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
    Runtime:addEventListener( "enterFrame", moveBackground)
		Runtime:addEventListener("collision", die)
    gameLoopTimer = timer.performWithDelay(1700, gameLoop, 0)
    audio.play(musicTrack, {channel=1, loops=1})
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
    Runtime:removeEventListener("enterFrame", moveBackground)
    audio.stop(1)
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  audio.dispose( musicTrack )
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