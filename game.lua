
local composer = require( "composer" )

local scene = composer.newScene()

local json = require("json")

local widget = require("widget")

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

local options = {width = 150, height = 150, numFrames = 11}
local sheet_CI = graphics.newImageSheet("media/CISheet.png", options)
local sequence_CI = {name="normalRun", start=1, count=8, time=800, loopCount=0, loopDirection="forward", }
local CI

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
local gameOverGroup

--declare the soundtracks
local musicTrack
local dingSound
local crashSound

local boat

-- ADMOB setup

local admob = require("plugin.admob")

local appID = "n/a"
local adUnits = {}
local platformName = system.getInfo("platform")
local testMode = true
local testModeButton
local showTestWarning = true
local iReady
local bReady
local rReady
local bannerLine
local oldOrientation

if platformName == "Android" or platformName == "android" then
  appID = "ca-app-pub-1014857154557988~1392609501"
  adUnits = {
    interstitial="ca-app-pub-1014857154557988/6910042957",
  }
else
  print "Unsupported platform"
end

local function adListener( event )
 
  if ( event.phase == "init" ) then  -- Successful initialization
      -- Load an AdMob interstitial ad
      admob.load( "interstitial", { adUnitId=adUnits.interstitial } )
  end
end

admob.init( adListener, { appId=appID, testMode=true } )

-- end of ADMOB setup

local function updateText()
  if(died == false) then
    peopleSavedText.text = " " .. peopleSaved
  end
end

local function gameSpeed(peopleSaved) --function to increase scroll speed and velocity depending on number of peopleSaved
  if(scrollSpeed < 7.9 and peopleSaved > 5) then
    scrollSpeed = scrollSpeed*1.025
    velocity = 58.82353*scrollSpeed
  end
end

local update = function() --this function is called on everytime the updateTimer goes off. This changes the delay of the spawnTimer timer.
	if (peopleSaved >= 13) then
		seconds = 920                  --fast...
		spawnTimer._delay = seconds
  end
  if (peopleSaved >= 26) then
    seconds = 600                  --even faster...
    spawnTimer._delay = seconds
  end
end

local function createDebris()       -- spawn debris function. Also removes debris when gone too far off screen
  local newDebris = display.newImageRect(boatGroup, "media/debris.png", 52, 48)
	table.insert(debrisTable, newDebris)
  physics.addBody(newDebris, "dynamic", {radius=21, bounce=1})
  newDebris.myName = "debris"
  newDebris.alpha = 0.9

  local xVal = math.random(3)
  local yVal = math.random(6)

  if(xVal == 1) then   -- picks one of three different channels on the screen to travel on
    newDebris.x = 60
  elseif(xVal == 2) then
    newDebris.x = 160
  else
    newDebris.x = 260
  end

  if(yVal == 1) then
    newDebris.y = -136
  elseif(yVal == 2) then
    newDebris.y = -202
  elseif(yVal == 3) then
    newDebris.y = -268
  elseif(yVal == 4) then
    newDebris.y = -334
  elseif(yVal == 5) then
    newDebris.y = -400
  else
    newDebris.y = -466
  end

  newDebris:setLinearVelocity(0, velocity)   --no x axis velocity. only y axis velocity
  newDebris:applyTorque(math.random(-1, 1)/3.5)  -- random amount of torque between -1 and 1

end

local function createPerson()  --create a person function (similar to createDebris function) with the same channel choosing idea as above
  local newPerson = display.newImageRect(boatGroup, "media/person.png", 46,64)
	table.insert(peopleTable, newPerson)
  physics.addBody(newPerson, "dynamic", {radius=40, bounce=1})
  newPerson.myName = "person"
  newPerson.alpha = 0.8

  local xVal = math.random(3)
  local yVal = math.random(6)

  if(xVal == 1) then   -- picks one of three different channels on the screen to travel on
    newPerson.x = 60
  elseif(xVal == 2) then
    newPerson.x = 160
  else
    newPerson.x = 260
  end

  if(yVal == 1) then
    newPerson.y = -136
  elseif(yVal == 2) then
    newPerson.y = -202
  elseif(yVal == 3) then
    newPerson.y = -268
  elseif(yVal == 4) then
    newPerson.y = -334
  elseif(yVal == 5) then
    newPerson.y = -400
  else
    newPerson.y = -466
  end

  newPerson:setLinearVelocity(0, velocity)
  newPerson:applyTorque(math.random(-1, 1)/3.5)  -- random amount of torque between -1 and 1

end

local function moveBoat (event) --touch to move boat function
  local phase = event.phase

  if("began" == phase) then
    display.currentStage:setFocus(boat)

  elseif("moved" == phase) then
    if (event.x < event.xStart and boat.x == 260) then
      transition.to( boat, { time=180-(peopleSaved*2), x=160, transition=easing.inOutCirc } )           --this function deals with the sliding action done by the user.
      transition.to( boat, { rotation=-10, time=180, transition=easing.inOutCubic } )   --this rotates the boat in the direction of slide

    elseif(event.x > event.xStart and boat.x == 60) then
      transition.to( boat, { time=180-(peopleSaved*2), x=160, transition=easing.inOutCirc } )
      transition.to( boat, { rotation=10, time=180, transition=easing.inOutCubic } )

    elseif(event.x < event.xStart and boat.x == 160) then
      transition.to( boat, { time=180-(peopleSaved*2), x=60, transition=easing.inOutCirc } )
      transition.to( boat, { rotation=-10, time=180, transition=easing.inOutCubic } )

    elseif(event.x > event.xStart and boat.x == 160) then
      transition.to( boat, { time=180-(peopleSaved*2), x=260, transition=easing.inOutCirc } )
      transition.to( boat, { rotation=10, time=180, transition=easing.inOutCubic } )

    end

  elseif("ended" == phase or "cancelled" == phase) then
    transition.to( boat, { rotation=0, time=200, transition=easing.inOutCubic } )   --this points the boat straight ahead once the users finger is lifted off
    display.currentStage:setFocus(nil)
  end
  return true
end

local function tapMove(event)   --tap to move boat function
  if(event.y < 40) then
    return
  end

  if(event.x <= 160) then
    if (boat.x == 260) then
      transition.to( boat, { time=180-(peopleSaved*2), x=160, transition=easing.inOutCirc } )      --same as above function it slides the boat over
      transition.to( boat, { rotation=-10, time=180, transition=easing.inOutCubic } )
    elseif(boat.x == 160) then
      transition.to( boat, { time=180-(peopleSaved*2), x=60, transition=easing.inOutCirc } )
      transition.to( boat, { rotation=-10, time=180, transition=easing.inOutCubic } )
    end
  elseif(event.x > 160) then
    if(boat.x == 60) then
      transition.to( boat, { time=180-(peopleSaved*2), x=160, transition=easing.inOutCirc } )
      transition.to( boat, { rotation=10, time=180, transition=easing.inOutCubic } )
    elseif(boat.x == 160) then
      transition.to( boat, { time=180-(peopleSaved*2), x=260, transition=easing.inOutCirc } )
      transition.to( boat, { rotation=10, time=180, transition=easing.inOutCubic } )
    end
  end

  transition.to( boat, { rotation=0, delay=150 ,time=180, transition=easing.inOutCubic } )

end

local function keyPressed( event )   --function for playing the game on the laptop is user presses left or right keys
  local key = event.keyName
  if(key == "left" and event.phase == "down") then   --the "down" part of this if statement is vital
    if(boat.x == 160) then                             --it will only move the boat to the left when the key is pressed down and not when left up
      transition.to( boat, { time=180-(peopleSaved*2), x=60, transition=easing.inOutCirc } )      --same as above function it slides the boat over
      transition.to( boat, { rotation=-10, time=200, transition=easing.inOutCubic } ) 
    end
    if(boat.x == 260) then                             --it will only move the boat to the left when the key is pressed down and not when left up
      transition.to( boat, { time=180-(peopleSaved*2), x=160, transition=easing.inOutCirc } )      --same as above function it slides the boat over
      transition.to( boat, { rotation=-10, time=200, transition=easing.inOutCubic } ) 
    end
  elseif(key == "right" and event.phase == "down") then
    if(boat.x == 160) then
      transition.to( boat, { time=180-(peopleSaved*2), x=260, transition=easing.inOutCirc } )      --same as above function it slides the boat over
      transition.to( boat, { rotation=10, time=200, transition=easing.inOutCubic } ) 
    end
    if(boat.x == 60) then
      transition.to( boat, { time=180-(peopleSaved*2), x=160, transition=easing.inOutCirc } )      --same as above function it slides the boat over
      transition.to( boat, { rotation=10, time=200, transition=easing.inOutCubic } ) 
    end
  end

  if((key == "left" or key == "right") and event.phase == "up") then
    transition.to( boat, { rotation=0, time=200, transition=easing.inOutCubic } )
  end

  if ( key == "back" ) then                                    -- if the "back" key was pressed on android prevent it from backing out of the app
    if ( system.getInfo("platform") == "android" ) then
      return true
    end
  end

  return false
end

local function gameLoop()
  
  if(died == false) then
    createPerson()
    createDebris()
  end

  for j = #peopleTable, 1, -1 do
    local thisPerson = peopleTable[j]

    if ( thisPerson.y > 700) then
      display.remove( thisPerson )   -- remove person gone too far
      table.remove( peopleTable, j )
    end

  end

  for i = #debrisTable, 1, -1 do
    local thisDebris = debrisTable[i]

    if ( thisDebris.y > 700) then
      display.remove( thisDebris )   -- remove debris gone too far
      table.remove( debrisTable, i )
    end

  end

end

local function startNewGame(event)
  CI.isVisible = false
  
  composer.gotoScene( "landingPage", {time=300, effect="crossFade"})
end

local function gotoHighScores()
  CI.isVisible = false
  
  composer.gotoScene("highscores", {time=400, effect="crossFade"})
end

local function boatDie(event)
  transition.to( boat, { time=4000, y=1500 } ) -- when the boat hits debris, it will stay on the debris like as if it has crashed and is stuck on the debris
end          


local function showScoreBox()

  if(admob.isLoaded( "interstitial" )) then
    admob.show("interstitial")
  end

  menuButton.isVisible = false
  peopleSavedText.isVisible = false

  local box = display.newRoundedRect(gameOverGroup, display.contentCenterX, display.contentCenterY, 200, 150, 25)
  box:setFillColor( 0.01, 0.09, 0.211 )
  box.stroke = {1,1,1}
  box.strokeWidth = 8

  local score = display.newText(gameOverGroup, " " .. peopleSaved, display.contentCenterX, 200, "media/arcadefont.ttf", 40)
  local playAgain = display.newText(gameOverGroup, "p lay  again", display.contentCenterX, 260, "media/arcadefont.ttf", 25)
  local highscores = display.newText(gameOverGroup, "high scores", display.contentCenterX, 290, "media/arcadefont.ttf", 25)

  playAgain:addEventListener("tap", startNewGame)
  highscores:addEventListener("tap", gotoHighScores)

  CI.isVisible = true
end

local function endGame()
  composer.setVariable("finalPeopleSaved", peopleSaved)
  died = true
  boatDie()
  audio.pause(1)
  audio.pause(2)
  showScoreBox()
  
end

local function die(event)           --function that deals with collision. the boat hit what and what to do as a result of that
  if(event.phase == "began") then
    local obj1 = event.object1
    local obj2 = event.object2

    if((obj1.myName == "boat" and obj2.myName == "debris") or
       (obj1.myName == "debris" and obj2.myName == "boat") and
       (died == false)) then
         died = true
         audio.play(crashSound, {channel=3})      --crash soundtrack is played
			   timer.performWithDelay(0, endGame)
    end

    if((obj1.myName == "boat" and obj2.myName == "person") or
       (obj1.myName == "person" and obj2.myName == "boat") and
       (died == false)) then
        peopleSaved = peopleSaved + 1  --increase score - people saved
        updateText() --call on function
        audio.play(dingSound, {channel=2})  --ding soundtrack is played to indicate sucessful person saved
        
        obj2.isVisible = false
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
  	composer.gotoScene("menu", {time=400, effect="crossFade"})
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()

  CI = display.newSprite(sheet_CI, sequence_CI)
	transition.to(CI, {5000, alpha=1})
	CI.x = display.contentCenterX+65
	CI.y = display.contentCenterY-30
	CI:scale(0.65, 0.65)
	CI:play()
  CI.isVisible = false

  math.randomseed( os.time() )

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	boatGroup = display.newGroup()
	sceneGroup:insert(boatGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

  gameOverGroup = display.newGroup()
	sceneGroup:insert(gameOverGroup)

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

	boat = display.newImageRect(boatGroup, "media/boat.png", 45, 110)
	boat.x = display.contentCenterX
	boat.y = display.contentHeight - 50
	physics.addBody(boat, {isSensor=true})  -- sensor true so that it detects collisions always
	boat.myName = "boat"
  boat.alpha = 0.9

	peopleSavedText = display.newText(uiGroup, " " .. peopleSaved, display.contentCenterX-5, 20, "media/arcadefont.ttf", 50)

  boat:addEventListener("touch", moveBoat) --touch listener for movement

  musicTrack = audio.loadStream("media/gameSong.mp3") --game soundrtrack

  menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX+110, 20, "media/arcadefont.ttf", 25)
  menuButton:setFillColor(1, 1, 1 )
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

    -- admob.load( "interstitial", { adUnitId=adUnits.interstitial } )

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
    
    CI.isVisible = false

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener("collision", die)
		physics.pause()
		composer.removeScene("game")
    Runtime:removeEventListener("enterFrame", moveBackground)
    Runtime:removeEventListener( "enterFrame", boatDie)
    audio.stop(1)
    timer.cancel(spawnTimer)
    timer.cancel(updateTimer)
    Runtime:removeEventListener("key", keyPressed)

    CI.isVisible = false

    if (CI ~= nil) then
      CI:removeSelf()
    end
    
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  -- audio.dispose( musicTrack )
  if (CI ~= nil) then
    CI:removeSelf()
  end
  
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
