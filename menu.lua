
local composer = require( "composer" )

local scene = composer.newScene()
display.setDefault( "background", 0,0,0 )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function gotoLS()
  composer.gotoScene("level1")
  local backgroundMusic = audio.loadSound("sound/bgm1.mp3")

local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=10000 } )
end

local function gotoShop()
  composer.gotoScene( "highscores" )
  local backgroundMusic = audio.loadSound("sound/bgm2.mp3")

local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=2000 } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  local background = display.newImageRect( sceneGroup, "images/menuBackgroundWIP.png", 1920, 1080 )
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local title = display.newImageRect( sceneGroup, "images/title.png", 1000, 600 )
  title.x = display.contentCenterX
  title.y = 300

  local lsButton = display.newText( sceneGroup, "Start the Game", display.contentCenterX, 800, native.systemFont, 44)
  lsButton:setFillColor(1, 1, 1)

  local shopButton = display.newText( sceneGroup, "Visit the Shop", display.contentCenterX, 910, native.systemFont, 44 )
  shopButton:setFillColor(1, 1, 1)

  lsButton:addEventListener( "tap", gotoLS)
  shopButton:addEventListener( "tap", gotoShop )
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
    composer.removeScene( "menu" )
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
