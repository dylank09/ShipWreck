
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
	  file:write( json.encode( scoresTable ) )
	  io.close( file )
	end
end

local function gotoMenu()
	composer.gotoScene("menu", {time=800, effect="crossFade"})
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	loadPeopleSaved()
	table.insert( peopleSavedTable, composer.getVariable( "finalScore" ) )
  composer.setVariable( "finalScore", 0 )

	local function compare( a, b )
		return a > b
  end
  table.sort( peopleSavedTable, compare )

	savePeopleSaved()

	--local background = display.newImageRect(sceneGroup, , 100, 100)
	--background.x = display.contentCenterX
	--background.y = display.contentCenterY

	local highScoresHeader = display.newText(sceneGroup, "High Scores", display.contentCenterX, 10, native.systemFont, 32)

	for i = 1, 10 do
		if(peopleSavedTable[i]) then
	  	local yPos = 35 + (i * 40)

			local rankNum = display.newText(sceneGroup, i .. ")", display.contentCenterX - 125, yPos, native.systemFont, 22)
			rankNum:setFillColor(0.8)
			rankNum.anchorX = 1

			local thisPeopleSaved = display.newText(sceneGroup, peopleSavedTable[i], display.contentCenterX - 120, yPos, native.systemFont, 25)
			thisPeopleSaved.anchorX = 0
		end
	end

  local menuButton = display.newText(sceneGroup, "Menu", display.contentCenterX+100, 480, native.systemFont, 25)
	menuButton:setFillColor(0.75, 0.78, 1)
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

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

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
