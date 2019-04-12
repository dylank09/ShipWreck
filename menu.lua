
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local options = {width = 150, height = 150, numFrames = 11}
local sheet_CI = graphics.newImageSheet("CISheet.png", options)
local sequence_CI = {name="normalRun", start=1, count=8, time=800, loopCount=0, loopDirection="forward", }
local CI
local storyLineMessage

local function gotoGame()
	composer.gotoScene("game", {time=600, effect="crossFade"})
end

local function gotoHighScores()
	composer.gotoScene("highscores", {time=600, effect="crossFade"})
end

local function gotoHowToPlay()
	composer.gotoScene("howToPlay", {time=600, effect="flipFadeOutIn"})
end

local function keyPressed( event )
	--gotoGame()
  -- If the "back" key was pressed on Android, prevent it from backing out of the app
  if ( key == "back" ) then
    if ( system.getInfo("platform") == "android" ) then
      return true
    end
  end
  return false
end

local function CIstory(event)
	if(storyLineMessage.isVisible) then
		storyLineMessage.isVisible = false
	else
		storyLineMessage.isVisible = true
	end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect(sceneGroup, "menupage.png", 320, 600)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	CI = display.newSprite(sheet_CI, sequence_CI)
	transition.to(CI, {5000, alpha=1})
	CI.x = display.contentCenterX+100
	CI.y = display.contentCenterY-60
	CI:scale(1, 1)
	CI:play()

	storyLineMessage = display.newImageRect(sceneGroup, "CIbox.png", 210, 110)
  storyLineMessage.x = display.contentCenterX + 2
	storyLineMessage.y = display.contentCenterY - 6
	storyLineMessage.isVisible = false

	local title = display.newImageRect(sceneGroup, "title1.png", 220,120)
	title.x = display.contentCenterX
	title.y = 45

	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 390, "arcadefont.ttf", 32 )
	playButton:setFillColor( 0.82, 0.86, 1 )

	local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 430, "arcadefont.ttf", 32 )
	highScoresButton:setFillColor( 0.82, 0.86, 1 )

	local howToPlayButton = display.newText(sceneGroup, "How To Play", display.contentCenterX, 470, "arcadefont.ttf", 32 )
	howToPlayButton:setFillColor( 0.82, 0.86, 1 )

	playButton:addEventListener( "tap", gotoGame )
  highScoresButton:addEventListener( "tap", gotoHighScores )
	howToPlayButton:addEventListener("tap", gotoHowToPlay)
	CI:addEventListener("tap", CIstory)
	storyLineMessage:addEventListener("tap", CIstory)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		Runtime:addEventListener( "key", keyPressed )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		Runtime:removeEventListener("key", keyPressed)
		transition.to(CI, {4000, alpha=0})
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
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
