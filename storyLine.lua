
local composer = require( "composer" )

local scene = composer.newScene()

local options = {width = 150, height = 150, numFrames = 11}
local sheet_CI = graphics.newImageSheet("media/CISheet.png", options)
local sequence_CI = {name="normalRun", start=1, count=8, time=800, loopCount=0, loopDirection="forward", }
local CI
local storyText

local json = require("json")

local fp = system.pathForFile("volume.json", system.DocumentsDirectory)

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function keyPressed( event )
	local key = event.keyName
	if((key == "enter" or key == "back" or key == "space" or key == "p")and event.phase == "down") then
    gotoMenu()
  end
  -- If the "back" key was pressed on Android, prevent it from backing out of the app
  if ( key == "back" ) then
    if ( system.getInfo("platform") == "android" ) then
      return true
    end
  end
  return false
end

function gotoHowToPlay()
	composer.gotoScene("howToPlay", {time=200, effect="flipFadeOutIn"})
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect(sceneGroup, "media/menupage.png", 320, 600)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	CI = display.newSprite(sheet_CI, sequence_CI)
	transition.to(CI, {5000, alpha=1})
	CI.x = display.contentCenterX-100
	CI.y = display.contentCenterY-120
	CI:scale(1, 1)
	CI:play()

	audio.setVolume(1)

	local file = io.open( fp, "w" )
	
	if file then
		file:write( json.encode( 1 ) )
	end

	io.close(file)

	local options = {
		scene = sceneGroup,
		text = " A  scientific  expedition \n through  the  Norwegian  Sea \n has  gone  horribly  wrong. \n\n\n Help  Captain  Ishka \n rescue  the  survivors \n and  avoid  the  debris. \n\n\n\n It's  a  race  against  time !",
		x = display.contentCenterX, 
		y = 280, 
		font = "media/arcadefont.ttf",
		fontSize = 21,
		align = "left"
	}

	storyText = display.newText( options )
	storyText:setFillColor( 0.82, 0.86, 1 )

  	local menuButton = display.newText(sceneGroup, "Next", display.contentCenterX+100, 490, "media/arcadefont.ttf", 26)
	menuButton:setFillColor( 0.82, 0.86, 0.6 )
	menuButton:addEventListener("tap", gotoHowToPlay)
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
		transition.to( CI, { time=200,
							 x=display.contentCenterX+100,
							 y=display.contentCenterY-60, 
							 transition=easing.inOutCirc,
							 alpha = 0 } )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

		storyText:removeSelf()
		CI:removeSelf()
		composer.removeScene("storyLine") --cleans up

		
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
