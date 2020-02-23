
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local json = require( "json" )

local pointsTotal

local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )


local function loadScores()

    local file = io.open( filePath, "r" )

    if file then
        local contents = file:read( "*a" )
        io.close( file )
        pointsTotal = json.decode( contents )
    end

    if ( pointsTotal == nil or #pointsTotal == 0 ) then
        pointsTotal = 0
    end
end

local function saveScores()



    local file = io.open( filePath, "w" )

    if file then
        file:write( json.encode( pointsTotal ) )
        io.close( file )
    end
end
local function gotoMenu()
    composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
loadScores()
table.insert( pointsTotal, composer.getVariable( "finalScore" ))
composer.setVariable( "finalScore", 0 )

local function compare( a, b )
	return a> b
end
table.sort(pointsTotal, compare)

saveScores()

local highScoresHeader = display.newText( sceneGroup, "Points Total", display.contentCenterX, 100, native.systemFont, 44 )

for i = 1, 1 do
		if ( pointsTotal[i] ) then
				local yPos = 150 + ( i * 56 )
local thisScore = display.newText( sceneGroup, pointsTotal[i], display.contentCenterX-30, yPos, native.systemFont, 36 )
thisScore.anchorX = 0
	end
	end
	local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, 810, native.systemFont, 44 )
menuButton:setFillColor( 0.75, 0.78, 1 )
menuButton:addEventListener( "tap", gotoMenu )
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
        composer.removeScene( "highscores" )
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
