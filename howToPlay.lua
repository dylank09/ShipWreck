
local composer = require( "composer" )

local scene = composer.newScene()

local volumeOnOffButton

local volume

local json = require("json")

local fp = system.pathForFile("volume.json", system.DocumentsDirectory)

local firstText, secondText

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

function gotoMenu()
	composer.gotoScene("menu", {time=200, effect="flipFadeOutIn"})
end

function volumeOnOff()
	
	local file = io.open( fp, "w" )
	
	if file then
		if(audio.getVolume() > 0) then
			volume = 0
			audio.setVolume(volume)
			volumeOnOffButton.text = "Volume : OFF"
			file:write( json.encode( volume ) )
		else
			volume = 1
			audio.setVolume(volume)
			volumeOnOffButton.text = "Volume : ON"
			file:write( json.encode( volume ) )
		end

		io.close(file)
	end

end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect(sceneGroup, "media/water.png", 320, 600)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	
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

		local options1 = {
			scene = sceneGroup,
			text = "GOAL:\n AVOID   obstacles \n RESCUE   the   crew",
			x = display.contentCenterX, 
			y = 170, 
			font = "media/arcadefont.ttf",
			fontSize = 25,
			align = "left"
		}
	
		local options2 = {
			scene = sceneGroup,
			text = "Tap   or   swipe \n to   move   the   boat",
			x = display.contentCenterX, 
			y = 300, 
			font = "media/arcadefont.ttf",
			fontSize = 27,
			align = "center"
		}
	
		firstText = display.newText( options1 )
	
		secondText = display.newText( options2 )
	
		firstText:setFillColor( 0.82, 0.86, 1 )
		secondText:setFillColor( 0.82, 0.86, 1 )

		local arrows = display.newImageRect(sceneGroup, "media/arrows.png", 200, 200)
		arrows.x = display.contentCenterX
		arrows.y = display.contentHeight - 50

		local boat = display.newImageRect(sceneGroup, "media/boat.png", 45, 110)
		boat.x = display.contentCenterX
		boat.y = display.contentHeight - 50
	
		local menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX+100, 500, "media/arcadefont.ttf", 25)
		menuButton:setFillColor(0, 0, 0)
		menuButton:addEventListener("tap", gotoMenu)
	
		volumeOnOffButton = display.newText(sceneGroup, "", display.contentCenterX-80, 500, "media/arcadefont.ttf", 25)
		volumeOnOffButton:setFillColor(0, 0, 0)
		volumeOnOffButton:addEventListener("tap", volumeOnOff)
	
		if(audio.getVolume() > 0) then
			volumeOnOffButton.text = "Volume : ON"
			audio.setVolume(1)
		else
			volumeOnOffButton.text = "Volume : OFF"
			audio.setVolume(0)
		end

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		Runtime:removeEventListener("key", keyPressed)
		firstText.isVisible = false
		secondText.isVisible = false

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene("howToPlay") --cleans up
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
