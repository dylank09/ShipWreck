
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)  --no gravity

--declare local variables
local middle = 160  --for use later on. specifies middle of screen
local menuButton
local boatx
local touchx
local peopleSaved = 0 --score starts at zero
local peopleSavedText
local died = false --boolean died value

--for scrolling the background, 3 had to be created
local backg1
local backg2
local backg3

--declare tables for debris and people
local debrisTable = {}
local peopleTable = {}

--more than one tier needed in order to increase spawn rate as the game goes on
local spawnTimer
local updateTimer

--variables for the scrolling background function
_W = display.contentWidth -- get the width of the screen
_H = display.contentHeight -- get the height of the screen
scrollSpeed = 3.4 -- set scroll speed of background
velocity = 58.82353*scrollSpeed --the velocity of people and debris MUST increase proportionally
seconds = 1600

--declare the display groups
local backGroup
local boatGroup
local uiGroup

--declare the soundtracks
local musicTrack
local dingSound
local crashSound

local boat

local function updateText()
  peopleSavedText.text = " " .. peopleSaved
end

local function gameSpeed(peopleSaved) --function to increase scroll speed and velocity depending on number of peopleSaved
  if(scrollSpeed < 7.9 and peopleSaved > 5) then
    scrollSpeed = scrollSpeed*1.025
    velocity = 58.82353*scrollSpeed
  end
end

local update = function() --this function is called on everytime the updateTimer goes off. This changes the delay of the spawnTimer timer.
	if (peopleSaved >= 14) then
		seconds = 920                  --fast...
		spawnTimer._delay = seconds
  end
  if (peopleSaved >= 26) then
    seconds = 600                  --even faster...
    spawnTimer._delay = seconds
  end
end

local function createDebris()       -- spawn debris function. Also removes debris when gone too far off screen
  local newDebris = display.newImageRect(boatGroup, "media/debris.png", 66, 62)
	table.insert(debrisTable, newDebris)
  physics.addBody(newDebris, "dynamic", {radius=30, bounce=0.8})
  newDebris.myName = "debris"
  newDebris.alpha = 0.70

  local xVal = math.random(3)

  if(xVal == 1) then   -- picks one of three different channels on the screen to travel on
    newDebris.x = 60
    newDebris.y = math.random(-450, -90)
  elseif(xVal == 2) then
    newDebris.x = 160
    newDebris.y = math.random(-470, -70)
  elseif(xVal == 3) then
    newDebris.x = 260
    newDebris.y = math.random(-420, -100)
  end
  newDebris:setLinearVelocity(0, velocity)   --no x axis velocity. only y axis velocity
  newDebris:applyTorque(math.random(-1, 1)/2.5)  -- random amount of torque between -1 and 1
end

local function createPerson()  --create a person function (similar to createDebris function) with the same channel choosing idea as above
  local newPerson = display.newImageRect(boatGroup, "media/person.png", 48,66)
	table.insert(peopleTable, newPerson)
  physics.addBody(newPerson, "dynamic", {radius=32, bounce=0.6})
  newPerson.myName = "person"
  newPerson.alpha = 0.9

  local xVal = math.random(3)

  if(xVal == 1) then
    newPerson.x = 60
    newPerson.y = math.random(-420, -100)
  elseif(xVal == 2) then
    newPerson.x = 160
    newPerson.y = math.random(-470, -70)
  elseif(xVal == 3) then
    newPerson.x = 260
    newPerson.y = math.random(-450, -90)
  end
  newPerson:setLinearVelocity(0, velocity)

end

local function moveBoat (event) --touch to move boat function
  --local boat = event.target
  local phase = event.phase

  if("began" == phase) then
    display.currentStage:setFocus(boat)
  elseif("moved" == phase) then
    if (event.x < event.xStart and boat.x == 260) then
      transition.to( boat, { time=200, x=160, transition=easing.inOutCirc } )           --this function deals with the sliding action done by the user.
      transition.to( boat, { rotation=-10, time=180, transition=easing.inOutCubic } )   --this rotates the boat in the direction of slide
    elseif(event.x > event.xStart and boat.x == 60) then
      transition.to( boat, { time=200, x=160, transition=easing.inOutCirc } )
      transition.to( boat, { rotation=10, time=180, transition=easing.inOutCubic } )
    elseif(event.x < event.xStart and boat.x == 160) then
      transition.to( boat, { time=200, x=60, transition=easing.inOutCirc } )
      transition.to( boat, { rotation=-10, time=180, transition=easing.inOutCubic } )
    elseif(event.x > event.xStart and boat.x == 160) then
      transition.to( boat, { time=200, x=260, transition=easing.inOutCirc } )
      transition.to( boat, { rotation=10, time=180, transition=easing.inOutCubic } )
    end

  elseif("ended" == phase or "cancelled" == phase) then
    transition.to( boat, { rotation=0, time=250, transition=easing.inOutCubic } )   --this points the boat straight ahead once the users finger is lifted off
    display.currentStage:setFocus(nil)
  end
  return true
end

local function tapMove(event)   --tap to move boat function
  if(event.x < 160) then
    if (boat.x == 260) then
      transition.to( boat, { time=200, x=160, transition=easing.inOutCirc } )      --same as above function it slides the boat over
      -- transition.to( boat, { rotation=-10, time=180, transition=easing.inOutCubic } )   --rotates it in direction it is going
    elseif(boat.x == 160) then
      transition.to( boat, { time=200, x=60, transition=easing.inOutCirc } )
      -- transition.to( boat, { rotation=-10, time=180, transition=easing.inOutCubic } )
    end
  elseif(event.x > 160) then
    if(boat.x == 60) then
      transition.to( boat, { time=200, x=160, transition=easing.inOutCirc } )
      -- transition.to( boat, { rotation=10, time=180, transition=easing.inOutCubic } )
    elseif(boat.x == 160) then
      transition.to( boat, { time=200, x=260, transition=easing.inOutCirc } )
      -- transition.to( boat, { rotation=10, time=180, transition=easing.inOutCubic } )
    end
  end


end

local function keyPressed( event )   --function for playing the game on the laptop is user presses left or right keys
  local key = event.keyName
  if(key == "left" and event.phase == "down") then   --the "down" part of this if statement is vital
    if(boat.x > 60) then                             --it will only move the boat to the left when the key is pressed down and not when left up
      transition.to( boat, { time=200, x=boat.x-100, transition=easing.inOutCirc } )      --same as above function it slides the boat over
      transition.to( boat, { rotation=-10, time=180, transition=easing.inOutCubic } ) 
    end
  elseif(key == "right" and event.phase == "down") then
    if(boat.x < 260) then
      transition.to( boat, { time=200, x=boat.x+100, transition=easing.inOutCirc } )      --same as above function it slides the boat over
      transition.to( boat, { rotation=10, time=180, transition=easing.inOutCubic } ) 
    end
  end
  if((key == "left" or key == "right") and event.phase == "up") then
    transition.to( boat, { rotation=0, time=250, transition=easing.inOutCubic } )
  end

  if ( key == "back" ) then                                    -- if the "back" key was pressed on android prevent it from backing out of the app
    if ( system.getInfo("platform") == "android" ) then
      return true
    end
  end

  return false
end

local function gameLoop()
  createPerson()
  createDebris()

  for i = #debrisTable, 1, -1 do
    local thisDebris = debrisTable[i]

    if ( thisDebris.y > 650) then
      display.remove( thisDebris )   -- remove debris gone too far
      table.remove( debrisTable, i )
    end
  end
end

local function boatDie(event)
  boat.y = boat.y + scrollSpeed  -- when the boat hits debris, it will stay on the debris like as if it has crashed and is stuck on the debris
end                              --this adds an excellent visual effect

local function endGame()
  composer.setVariable("finalPeopleSaved", peopleSaved)
	composer.gotoScene("highscores", {time=600, effect="crossFade"})  --go to highscores when dead or when menu is clicked
end

local function die(event)           --function that deals with collision. the boat hit what and what to do as a result of that
  if(event.phase == "began") then
    local obj1 = event.object1
    local obj2 = event.object2

    if((obj1.myName == "boat" and obj2.myName == "debris") or
       (obj1.myName == "debris" and obj2.myName == "boat") and
       (died == false)) then
         died = true
         audio.play(crashSound)      --crash soundtrack is played
			   timer.performWithDelay(0, endGame)
    end

    if((obj1.myName == "boat" and obj2.myName == "person") or
       (obj1.myName == "person" and obj2.myName == "boat") and
       (died == false)) then
        peopleSaved = peopleSaved + 1  --increase score - people saved
        updateText() --call on function
        audio.play(dingSound)  --ding soundtrack is played to indicate sucessful person saved
        display.remove(obj2) -- remove from display
        gameSpeed(peopleSaved)  --call on function that increases scroll speed and velocity depending on amount of people saved
    end
  end
end

local function moveBackground(event) --scroll background function

  -- move backgrounds to the left by scrollSpeed
  backg1.y = backg1.y + scrollSpeed
  backg2.y = backg2.y + scrollSpeed
  backg3.y = backg3.y + scrollSpeed

  --create listeners for when backgrounds passes a certain point off screen
  --move the background to the top when gone passed the point
  if (backg1.y + backg1.contentWidth) > 1300 then
    backg1:translate( 0, -480*3 )
  end
  if (backg2.y + backg2.contentWidth) > 1300 then
    backg2:translate( 0, -480*3 )
  end
  if (backg3.y + backg3.contentWidth) > 1300 then
    backg3:translate( 0, -480*3 )
  end
end

local function gotoMenu()
  	composer.gotoScene("menu", {time=500, effect="crossFade"})
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

  -- ddd first background
  backg1 = display.newImageRect(backGroup, "media/water.png", 320, 480)
  backg1.x = display.contentCenterX
  backg1.y = _H/2

  -- add second background
  backg2 = display.newImageRect(backGroup, "media/water.png", 320, 480)
  backg2.x = display.contentCenterX
  backg2.y = backg1.y+480

  -- add third background
  backg3 = display.newImageRect(backGroup, "media/water.png", 320, 480)
  backg3.x = display.contentCenterX
  backg3.y = backg2.y+480

  local left = display.newImageRect(boatGroup, "media/water.png", 160, 600)  --invisible image for hit detection in order to move the boat left
  left.x = display.contentCenterX-80
  left.y = display.contentCenterY
  left.isVisible = false
  left.isHitTestable = true
  left:addEventListener("tap", tapMove)

  local right = display.newImageRect(boatGroup, "media/water.png", 160, 600)  --invisible image for hit detection in order to move the boat right
  right.x = display.contentCenterX+80
  right.y = display.contentCenterY
  right.isVisible = false
  right.isHitTestable = true
  right:addEventListener("tap", tapMove)

	boat = display.newImageRect(boatGroup, "media/boat.png", 60, 125)
	boat.x = display.contentCenterX
	boat.y = display.contentHeight - 50
	physics.addBody(boat, {isSensor=true})  -- sensor true so that it detects collisions always
	boat.myName = "boat"

	peopleSavedText = display.newText(uiGroup, " " .. peopleSaved, 155, 20, "media/arcadefont.ttf", 50)

  boat:addEventListener("touch", moveBoat) --touch listener for movement

  musicTrack = audio.loadStream("media/gameSong.mp3") --game soundrtrack

  menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX+110, 0, "media/arcadefont.ttf", 25)
  menuButton:setFillColor(1, 0.3, 0.2)
  menuButton:addEventListener("tap", endGame)

  dingSound = audio.loadSound("media/ding.wav")
  crashSound = audio.loadSound("media/crash.wav")

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
    updateTimer = timer.performWithDelay(50, update, 0)
    spawnTimer = timer.performWithDelay(seconds, gameLoop, 0)
		physics.start()
    Runtime:addEventListener( "enterFrame", moveBackground)
		Runtime:addEventListener("collision", die)
    Runtime:addEventListener( "key", keyPressed ) --for playing game on pc or laptop
    audio.play(musicTrack, {channel=1, loops=1})  --loops the game soundtrack. puts it on chanel one (nb)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    Runtime:addEventListener( "enterFrame", boatDie)
    audio.stop(1)
    timer.cancel(spawnTimer)
    timer.cancel(updateTimer)
    Runtime:removeEventListener("key", keyPressed)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener("collision", die)
		physics.pause()
		composer.removeScene("game")
    Runtime:removeEventListener("enterFrame", moveBackground)
    Runtime:removeEventListener( "enterFrame", boatDie)
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
