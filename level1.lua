
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- include Corona's "physics" library --------------------------------------------------------------------------------

--physics stuff
local physics = require "physics"
physics.start()
physics.setGravity( 0, 22)
physics.setScale( 80 )
physics.setDrawMode( "hybrid" )


-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local tapCount = 0
local power = 0
local foodEaten = 0
local foodTable = {"food1", "food2", "food3"}
local backGroup
local mainGroup
local uiGroup
local catballX = 0
local catballY = 0
local totalDistance = 0
local totalScore = 0
local scoreText
local gameLoopTimer
local enemiesDefeated = 0
backGroup = display.newGroup()
mainGroup = display.newGroup()
uiGroup = display.newGroup()
math.randomseed(os.time())

--------------------------------------------------------------------------------
-- Camera stuff
--------------------------------------------------------------------------------
local x, y = display.contentCenterX, display.contentCenterY
local cam = display.newRect( x, y, 9999999, 9999999 )
cam.fill = { type = "image", filename = "images/background2.png" }
cam.fill.scaleX = 0.00025
cam.fill.scaleY = 0.000138
--camera scrolling effect)
local camera = display.newGroup();
camera.x = 0
camera:insert( cam )

--------------------------------------------------------------------------------
-- End Level condition and sound test
--------------------------------------------------------------------------------


local function audioTest()

  local finishTest = audio.loadSound("sound/correct.swf.mp3")

  if totalDistance >= 2000 and totalScore >= 15000 then
    audio.play( finishTest )
  end
end
Runtime:addEventListener("enterFrame", audioTest)

--local function easterEgg()

--  local surprise = audio.loadSound("sound/")

--end
--Runtime:addEventListener("enterFrame", surprise)

--local function nomNom()

--  local heavyNom = audio.loadSound("sound/")


--end
--Runtime:addEventListener("enterFrame", audioTest)


--Sounds needed.
--When food is eaten, appropriate enemy sounds, cat impact sounds,pain, end 'jingle'


--Ugrades Below
--3 Different cats (Vary statistics)
--click upgrades
--Special food spawn (Once purchased in shop will spawn a high value food in all levels)


--shoots cat to the right based on taps have occurred
local function rotatecat()
  tapCount = tapCount + 1
  local tapText = tapCount
  cat:applyForce(power, - power, cat.x, cat.y)
  cat:applyAngularImpulse(500)
  power = power + math.round(tapCount + totalDistance / 1000) + foodEaten * 100 + enemiesDefeated * 10
end





local function endGame()
  composer.gotoScene( "highscores", { time = 800, effect = "crossFade" } )
  Runtime:removeEventListener(onEnterFrame)
end

--updates ui elements
local function updateText()
  foodText.text = "Food Consumed:  " .. foodEaten
  tapText.text = "Total Taps:  " .. tapCount
  powerText.text = "Power: ".. power
  distanceText.text = "Total Distance: " .. totalDistance
  totalScore = ((power - tapCount * 5) + (foodEaten * 500) + (totalDistance * 10) / 2)
  scoreText.text = "Score: "..totalScore

  if ( foodEaten == 1 ) then
    timer.performWithDelay( 0, endGame, 1 )
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
  --------------------------------------------------------------------------------
  --gameLoop functionality
  --------------------------------------------------------------------------------
  local function gameLoop()

    --------------------------------------------------------------------------------
    --Collision
    --------------------------------------------------------------------------------
    --Adds collision rules to erase food when it contacts Catball and alter velocity, also removes enemies on contact

    function onCollision( event )
      if (event.phase == "began" ) then
        if event.object1.myName == "Catball" and event.object2.myName == "food" then
          foodEaten = foodEaten + 1
          CBx, CBy = event.object1:getLinearVelocity()
          event.object1:setLinearVelocity( CBx + CBy + 1200, - CBy - power - 2200)
          event.contact.isEnabled = false
          event.object2:removeSelf()
          event.object2 = nil
        elseif event.object1.myName == "Catball" and event.object2.myName == "enemy" then
          enemiesDefeated = enemiesDefeated + 1
          CBx, CBy = event.object1:getLinearVelocity()
          event.object1:setLinearVelocity( CBx + 1800, CBy - 3500)
          event.contact.isEnabled = false
          event.object2:removeSelf()
          event.object2 = nil
        end
      end
    end
      Runtime:addEventListener( "collision", onCollision)
    -- Food Spawns
    --foodXSpawn set to 1000 pixels
    local foodXSpawn = 650
    local foodSpacer = 750
    --food spawned for 500 of each item over an increasing distance.
    for i = 1, 500 do
      local food1 = display.newImage( mainGroup, "images/food1.png") food1:scale( 0.3, 0.3)
      physics.addBody( food1, "static", { radius = 65, density = 0, friction = 1, bounce = 0.5} )
      food1.myName = "food"
      food1.x = foodXSpawn + foodSpacer * 1.2
      food1.y = 985
      foodXSpawn = foodXSpawn + 600
      local food2 = display.newImage( mainGroup, "images/food2.png") food2:scale( 0.5, 0.5)
      physics.addBody( food2, "static", { radius = 90, density = 0, friction = 1, bounce = 0.5} )
      food2.myName = "food"
      food2.x = foodXSpawn + foodSpacer * 1.6
      food2.y = 960
      foodXSpawn = foodXSpawn + 600
      local food3 = display.newImage( mainGroup, "images/food3.png" ) food3:scale( 1, 1)
      physics.addBody( food3, "static", { radius = 50, density = 0, friction = 1, bounce = 0.5} )
      food3.myName = "food"
      food3.x = foodXSpawn + foodSpacer * 1.8
      food3.y = 970
      foodXSpawn = foodXSpawn + foodSpacer * 1.4
      foodSpacer = foodSpacer * 1.1
      camera:insert(food1)
      camera:insert(food2)
      camera:insert(food3)
    end

    -- Enemy Spawns
    local enemy = {}

    for i = 1, 250 do
      enemy[i] = display.newImage( mainGroup, "images/enemy1.png" ) enemy[i]:scale( 0.5, 0.5)
      physics.addBody( enemy[i], "static", { radius = 50, density = 1, friction = 1, bounce = 2} )
      enemy[i].x = 4000 + math.random(display.screenOriginX, display.contentWidth * 100)
      enemy[i].y = -7500 + math.random(display.screenOriginY, display.contentHeight * 7)
      enemy[i].myName = "enemy"
      camera:insert(enemy[i])
    end
  end
  local beginGameLoop = function() return gameLoop() end
  timer.performWithDelay( 0, gameLoop, 1 )
  --------------------------------------------------------------------------------
  --Backgrounds
  --------------------------------------------------------------------------------
  display.setDefault( "background", 72, 209, 204 )
  display.setDefault( "textureWrapX", "repeat" )
  display.setDefault( "textureWrapY", "repeat" )
  -- X-Axis looping background
  bgDistanceX = 1080
  bgDistanceY = 700
  for i = 1, 1000 do
    sky = display.newImage( backGroup, "images/background1.png", bgDistanceX, 700, true )
    bgDistanceX = bgDistanceX + 2365
    camera:insert( sky )
  end

  --------------------------------------------------------------------------------
  --Catball
  --------------------------------------------------------------------------------
  --Catball Spawn
  cat = display.newImage( mainGroup, "images/cat.png", 500, 500 ) cat:scale( 0.15, 0.15)
  cat.bodyType = "kinematic"
  cat.x = display.actualContentWidth - 1500
  cat.y = display.actualContentHeight - 124
  camera:insert( cat )
  cat.myName = "Catball"

  --adds physics to Catball
  physics.addBody( cat, { radius = 72, density = 1, friction = 0.5, bounce = .6} )
  cat.linearDamping = .35
  cat.angularDamping = .05

  --------------------------------------------------------------------------------
  --Geometry
  --------------------------------------------------------------------------------
  local floor = display.newRect(0, 0, 500000, 50 )
  floor.anchorX = 0
  floor.anchorY = 1
  floor.x, floor.y = 0, 1080
  physics.addBody( floor, "static", { friction = 2.5, shape = floorShape, bounce = 00 } )

  local wall = display.newRect( 0, 600, 1, 500000 )
  wall.x, wall.y = 0, 1080
  physics.addBody( wall, "static", { friction = 1.5, bounce = 0.5 } )
  camera:insert(floor)

  --------------------------------------------------------------------------------
  --UI Elements
  --------------------------------------------------------------------------------
  foodText = display.newText(uiGroup, "Power: ", 1500, 80, native.systemFont, 36)
  foodText:setFillColor( 0, 0, 0 )

  tapText = display.newText(uiGroup, "Total taps:  " .. tapCount, 1500, 120, native.systemFont, 36 )
  tapText:setFillColor( 0, 0, 0 )

  powerText = display.newText(uiGroup, "Power: " .. power, 1500, 160, native.systemFont, 36)
  powerText:setFillColor( 0, 0, 0 )

  distanceText = display.newText(uiGroup, "Total Distance: " .. totalDistance - 420, 1500, 200, native.systemFont, 36)
  distanceText:setFillColor( 0, 0, 0 )

  scoreText = display.newText(uiGroup, "Score: " .. totalScore - 420, 1500, 240, native.systemFont, 36)
  scoreText:setFillColor( 0, 0, 0 )

  -- Camera follows cat automatically
  local function moveCamera()
    if (foodEaten >= 0 and cat.x ~= nil)then
      if (cat.x > 0)then
        camera.x = -cat.x + 300
        camera.y = -cat.y + 500
      end
    elseif (cat == nil) then
    end
  end

  Runtime:addEventListener( "enterFrame", updateText)
  Runtime:addEventListener( "enterFrame", moveCamera )
  Runtime:addEventListener( "tap", rotatecat)

  sceneGroup:insert( cam )
  sceneGroup:insert( camera )
  sceneGroup:insert( backGroup )
  sceneGroup:insert( mainGroup )
  sceneGroup:insert( uiGroup )

end

-- show()
function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    local previous = composer.getSceneName( "previous" )
    if previous ~= "main" and previous then
      composer.removeScene( previous, false)
    end
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen

    --prevents cat from moving before ten seconds have passed
    local function tapperCountdown( event )
      physics.start()
      Runtime:removeEventListener( "tap", rotatecat)
    end
    timer.performWithDelay( 3000, tapperCountdown)

  end
end

-- hide()
function scene:hide( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    physics.stop()
    composer.removeScene( "level1", false )
    Runtime:removeEventListener(moveCamera)
    Runtime:removeEventListener(onCollision)
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