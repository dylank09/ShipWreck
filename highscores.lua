
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local json = require("json")

local peopleSavedTable = {}

local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)

local function loadPeopleSaved()
	local file = io.open(filePath, "r")

	if file then
		local contents = file:read("*a")
		io.close(file)
		peopleSavedTable = json.decode(contents)
	end

	if (peopleSavedTable == nil or #peopleSavedTable == 0) then
		peopleSavedTable = {0,0,0,0,0,0,0,0,0,0}
	end
end


local function savePeopleSaved()

	for i = #peopleSavedTable, 11, -1 do
		table.remove(peopleSavedTable, i)
	end

	local file = io.open( filePath, "w" )

	if file then
	  file:write( json.encode( peopleSavedTable ) )
	  io.close( file )
	end
end

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
	composer.gotoScene("menu", {time=400, effect="crossFade"})
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	loadPeopleSaved()
	table.insert( peopleSavedTable, composer.getVariable( "finalPeopleSaved" ) )
  	composer.setVariable( "finalPeopleSaved", 0 )

	local function compare( a, b )
		return a > b
	end

	table.sort( peopleSavedTable, compare )

	savePeopleSaved()

	local highScoresHeader = display.newText(sceneGroup, "High Scores", display.contentCenterX+8, 13, "media/arcadefont.ttf", 29)

	for i = 1, 10 do
		if(peopleSavedTable[i]) then
	  	local yPos = 35 + (i * 40)

			local rankNum = display.newText(sceneGroup, i .. ")", display.contentCenterX - 125, yPos, "media/arcadefont.ttf", 16)
			rankNum:setFillColor(1, 0.7, 0)
			rankNum.anchorX = 1

			local thisPeopleSaved = display.newText(sceneGroup, peopleSavedTable[i], display.contentCenterX - 120, yPos, "media/arcadefont.ttf", 25)
			thisPeopleSaved.anchorX = 0
		end
	end

  	local menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX+110, 510, "media/arcadefont.ttf", 25)
	menuButton:setFillColor(0.82, 0.86, 1 )
	menuButton:addEventListener("tap", gotoMenu)
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
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene("highscores") --cleans up
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
