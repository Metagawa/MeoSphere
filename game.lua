local composer = require("composer")
local scene = composer.newScene()
math.randomseed(os.time())

audio.reserveChannels(1)
--------------------------------------------------------------------------------
-- include Corona's "physics" library
--------------------------------------------------------------------------------

--physics declarations
local physics = require "physics"
physics.start()
physics.pause()
physics.setGravity(0, 22)
physics.setScale(80)
physics.setDrawMode("normal")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- forward declarations and other locals
local tapCount = 0
local power = 0
local tapTimer
local foodEaten = 0
local catballX = 0
local catballY = 0
local totalDistance = 0
totalScore = 0
local scoreText
local secondsLeft = 5
local secondsGame = 60
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()
local enemiesDefeated = 0
local backgroundMusic
local soundTable = {
  nomSound = audio.loadSound("sound/nom.wav"), --https://freesound.org/people/xtrgamr/sounds/253615/
  duckSound = audio.loadSound("sound/quack.wav"), --https://freesound.org/people/crazyduckman/sounds/185549/
  oofSound = audio.loadSound("sound/oof1.mp3"), --http://soundbible.com/free-sound-effects-1.html
  hurtSound = audio.loadSound("sound/hurt1.wav") --http://soundbible.com/free-sound-effects-1.html
}

display.setDefault("background", 0, 0, 0)
display.setDefault("textureWrapX", "repeat")
display.setDefault("textureWrapY", "repeat")

--Camera declarations (sky background)
local x, y = display.contentCenterX, display.contentCenterY
local cam = display.newRect(x, y, 499999, 54000)
cam.fill = {type = "image", filename = "images/sky.png"}

local cam2 = display.newRect(x, - 275500, 499999, 499999)
cam2.fill = {type = "image", filename = "images/space_bg.png"}
cam.fill.scaleX = 0.0087
cam.fill.scaleY = 0.0590
cam2.fill.scaleX = 0.0029
cam2.fill.scaleY = 0.0029
--Timer Upgrade conditions
if (upgrade7 == true) then
  secondsGame = secondsGame + 30
elseif (upgrade8 == true) then
  secondsGame = secondsGame + 120
elseif (upgrade9 == true) then
  secondsGame = secondsGame + 240
end

-----------------------------------------------------
--function declarations
-----------------------------------------------------

--function to go to main menu
local function gotoMenu()
  composer.gotoScene("menu")
end

--function to go to shop
local function gotoShop()
  carriedScore = carriedScore + totalScore
  composer.setVariable("finalScore", totalScore)
  composer.gotoScene("shop")
end

--function to reset the game
local function resetGame()
  composer.gotoScene("tips")
end

--function to end the game
local function endGame()
  carriedScore = carriedScore + totalScore
  composer.setVariable("finalScore", totalScore)
  physics.stop()
  composer.gotoScene("shop")
  timer.cancel(endGameTimer)
end

local function resumeGame()
  physics.start()
  timer.resume(gameTimeRemainingTimer)
  timer.resume(endGameTimer)
  pauseButton.alpha = 1
  pauseBG.alpha = 0
  shopButton:removeEventListener("tap", gotoShop)
  shopButton.alpha = 0
  shopButtonText.alpha = 0
  resetButton:removeEventListener("tap", resetGame)
  resetButton.alpha = 0
  resetButtonText.alpha = 0
  lsButton:removeEventListener("tap", gotoMenu)
  lsButton.alpha = 0
  lsButtonText.alpha = 0
  resumeButton:removeEventListener("tap", resumeGame)
  resumeButton.alpha = 0
  foodText.alpha = 0
  speedText.alpha = 0
  distanceText.alpha = 0
end

local function pauseGame()
  physics.pause()
  timer.pause(gameTimeRemainingTimer)
  timer.pause(endGameTimer)
  pauseButton.alpha = 0
  pauseBG.alpha = 1
  shopButton:addEventListener("tap", gotoShop)
  shopButton.alpha = 1
  shopButtonText.alpha = 1
  resetButton:addEventListener("tap", resetGame)
  resetButton.alpha = 1
  resetButtonText.alpha = 1
  lsButton:addEventListener("tap", gotoMenu)
  lsButton.alpha = 1
  lsButtonText.alpha = 1
  resumeButton:addEventListener("tap", resumeGame)
  resumeButton.alpha = 1
  foodText.alpha = 1
  speedText.alpha = 1
  distanceText.alpha = 1
end

--this rotates the cat and shoots him to the right with increasing strength the more taps have occurred
local function rotatecat()
  if (upgrade1 == true) then
    tapCount = tapCount + 2
  end
  if (upgrade2 == true) then
    tapCount = tapCount + 10
  end
  if (upgrade3 == true) then
    tapCount = tapCount + 50
  else
    tapCount = tapCount + 1
  end
  local tapText = tapCount
  cat:applyForce(power, - power, cat.x, cat.y)
  cat:applyAngularImpulse(500)
  power = power + math.round(tapCount + totalDistance / 1000) + foodEaten * 100 + enemiesDefeated * 10
end

--onscreen clock codes
local function updateTime()
  secondsLeft = secondsLeft - 1
  local timeDisplay = secondsLeft
  clockText.text = timeDisplay
  if (secondsLeft == 0) then
    clockText.alpha = 0
    clockBG.alpha = 0
    tapWarn.alpha = 0
  end
end

local function gameTimeRemaining(event)
  secondsGame = secondsGame - 1
  gameClockText.text = secondsGame
  if (secondsGame == 0) then
    gameClockText.alpha = 0
    gameClockBG.alpha = 0
  end
end

dasbootuses = 3
local function dasboot(event)
  cat:setLinearVelocity(5000, - 5000)
  dasbootuses = dasbootuses - 1
  if (dasbootuses < 1) then
    dasbooticon:removeEventListener("tap", dasboot)
    dasbooticon.alpha = 0.5
  end
end

catnipuses = 1
local function catnip(event)
  catnipuses = catnipuses - 1
  dasbootuses=3
  if (catnipuses < 1) then
    catnipicon:removeEventListener("tap", catnip)
    catnipicon.alpha = 0.5
  end
end

--prevents cat from moving before ten seconds have passed
local function tapperCountdown(event)
  physics.start()
  Runtime:removeEventListener("tap", rotatecat)
  pauseButton:addEventListener("tap", pauseGame)
  dasbooticon:addEventListener("tap", dasboot)
  catnipicon:addEventListener("tap", catnip)
  gameTimeRemainingTimer = timer.performWithDelay(1000, gameTimeRemaining, secondsGame)
end


--------------------------------------------------------------------------------
--Collision
--------------------------------------------------------------------------------
--Adds collision rules to erase food when it contacts Catball and alter velocity, also removes enemies on contact
function onCollision(event)
  CBx, CBy = cat:getLinearVelocity()
  if (event.phase == "began") then
    power = power + math.round(tapCount + totalDistance / 1000) + foodEaten * 2 + enemiesDefeated * 10
    if
    event.object1.myName == "Catball" and event.object2.myName == "food" or
    event.object1.myName == "food" and event.object2.myName == "Catball"
    then
      if (upgrade4 == true) then
        foodEaten = foodEaten + 5
      elseif (upgrade5 == true) then
        foodEaten = foodEaten + 15
      elseif (upgrade6 == true) then
        foodEaten = foodEaten + 50
      else
        foodEaten = foodEaten + 1
      end
      cat:setLinearVelocity((CBx + power), - 500 - (CBy + power))
      event.contact.isEnabled = false
      event.object2:removeSelf()
      event.object2 = nil
      audio.play(soundTable["nomSound"])
    elseif
      event.object1.myName == "Catball" and event.object2.myName == "enemy" or
      event.object1.myName == "enemy" and event.object2.myName == "Catball"
      then
        enemiesDefeated = enemiesDefeated + 1
        foodEaten = foodEaten + 5
        cat:setLinearVelocity(CBx + power / 2, CBy - power / 2)
        event.contact.isEnabled = false
        event.object2:removeSelf()
        event.object2 = nil
        audio.play(soundTable["duckSound"])
      elseif
        event.object1.myName == "Catball" and event.object2.myName == "floor" or
        event.object1.myName == "floor" and event.object2.myName == "Catball"
        then
          audio.play(soundTable["oofSound"])
        elseif
          event.object1.myName == "Catball" and event.object2.myName == "obstacle" or
          event.object1.myName == "obstacle" and event.object2.myName == "Catball"
          then
            physics.pause()
            event.contact.isEnabled = false
            cat:setLinearVelocity(0, 0)
            audio.play(soundTable["hurtSound"])
            timer.performWithDelay(300, gotoShop, 1)
          end
        end
      end

      -- -----------------------------------------------------------------------------------
      -- Scene event functions
      -- -----------------------------------------------------------------------------------
      -- create()
      function scene:create(event)
        local sceneGroup = self.view
        -- Code here runs when the scene is first created but has not yet appeared on screen
        --Pause menu display code
        pauseBG = display.newImageRect(uiGroup, "images/pauseBG.png", 1920, 1080)
        pauseBG.x = display.contentCenterX
        pauseBG.y = display.contentCenterY
        pauseBG.alpha = 0

        lsButton = display.newImageRect(uiGroup, "images/white_button_dark.png", 300, 200)
        lsButton.x = display.contentCenterX - 300
        lsButton.y = 750
        lsButton.alpha = 0
        lsButtonText = display.newText(uiGroup, "Main Menu", display.contentCenterX - 300, 750, native.systemFont, 35)
        lsButtonText:setFillColor(0, 0, 0)
        lsButtonText.alpha = 0

        shopButton = display.newImageRect(uiGroup, "images/white_button_dark.png", 300, 200)
        shopButton.x = display.contentCenterX
        shopButton.y = 750
        shopButton.alpha = 0
        shopButtonText = display.newText(uiGroup, "Visit the Shop", display.contentCenterX, 750, native.systemFont, 35)
        shopButtonText:setFillColor(0, 0, 0)
        shopButtonText.alpha = 0

        resetButton = display.newImageRect(uiGroup, "images/white_button_dark.png", 300, 200)
        resetButton.x = display.contentCenterX + 300
        resetButton.y = 750
        resetButton.alpha = 0
        resetButtonText = display.newText(uiGroup, "Reset", display.contentCenterX + 300, 750, native.systemFont, 35)
        resetButtonText:setFillColor(0, 0, 0)
        resetButtonText.alpha = 0

        pauseButton = display.newImageRect(uiGroup, "images/pause.png", 75, 75)
        pauseButton.x = display.contentCenterX + 800
        pauseButton.y = 50
        pauseButton.alpha = 1

        resumeButton = display.newImageRect(uiGroup, "images/play.png", 75, 75)
        resumeButton.x = display.contentCenterX + 800
        resumeButton.y = 50
        resumeButton.alpha = 0

        dasbooticon = display.newImageRect(uiGroup, "images/dasboot.png", 100, 100)
        dasbooticon.x = display.contentCenterX + 850
        dasbooticon.y = 1000
        dasbooticon.alpha = 1

        catnipicon = display.newImageRect(uiGroup, "images/catnip.png", 100, 100)
        catnipicon.x = display.contentCenterX + 850
        catnipicon.y = 850
        catnipicon.alpha = 1

        --adds a circle and skins a cat onto it
        cat = display.newImage(mainGroup, "images/cat.png", 500, 500)
        cat:scale(0.53, 0.53)
        cat.bodyType = "kinematic"
        cat.x = display.actualContentWidth - 1500
        cat.y = display.actualContentHeight - 124

        --adds physics to Catball and gives him circle physics.
        physics.addBody(cat, {radius = 72, density = 1, friction = 0.5, bounce = .6})
        cat.myName = "Catball"
        cat.linearDamping = .35
        cat.angularDamping = .05

        --------------------------------------------------------------------------------
        -- Camera stuff
        --------------------------------------------------------------------------------

        -- Camera follows cat automatically
        function moveCamera()
          if (cat.x > 0) then
            camera.x = -cat.x + 300
            camera.y = -cat.y + 680
          end
        end
        --camera scrolling effect)
        camera = display.newGroup()
        camera.x = 0
        camera:insert(cam)
        camera:insert(cam2)
        -- X-Axis looping background
        bgDistanceX = 1080
        bgDistanceY = 700
        for i = 1, 1000 do
          sky = display.newImage("images/bg1.png", bgDistanceX, 830, true)
          bgDistanceX = bgDistanceX + 1920
          camera:insert(sky)
        end
        --tracks Catball's position at all times.
        function catballPosCalc(event)
          catballX = math.round(cat.x)
          catballY = math.round(cat.y)
          totalDistance = math.round(catballX / 100)
        end

        camera:insert(cat)

        --------------------------------------------------------------------------------
        --Geometry
        --------------------------------------------------------------------------------
        local floor = display.newRect(0, 0, 500000, 50)
        floor.anchorX = 0
        floor.anchorY = 1
        floor.x, floor.y = 0, 1078
        floor.alpha = 0
        floor.isHitTestable = true
        physics.addBody(floor, "static", {friction = 999, bounce = 0})
        floor.myName = "floor"

        local wall = display.newRect(0, 600, 1, 500000)
        wall.x, wall.y = 0, 1080
        physics.addBody(wall, "static", {friction = 1.5, bounce = 0.5})

        camera:insert(floor)

        --------------------------------------------------------------------------------
        -- Food Spawns
        --------------------------------------------------------------------------------
        --foodXSpawn set to 650 pixels
        local foodXSpawn = 650
        local foodSpacer = 1200
        --food spawned for 500 of each item over an increasing distance.
        local food = {}
        for i = 1, 500 do
          local food1 = display.newImage(mainGroup, "images/food1.png")
          food1:scale(0.3, 0.3)
          physics.addBody(food1, "static", {radius = 65, density = 0, friction = 1, bounce = 0.5})
          food1.myName = "food"
          food1.x = foodXSpawn + foodSpacer * 1.3
          food1.y = 985
          foodXSpawn = foodXSpawn + 600
          local food2 = display.newImage(mainGroup, "images/food2.png")
          food2:scale(0.5, 0.5)
          physics.addBody(food2, "static", {radius = 90, density = 0, friction = 1, bounce = 0.5})
          food2.myName = "food"
          food2.x = foodXSpawn + foodSpacer * 1.6
          food2.y = 960
          foodXSpawn = foodXSpawn + 600
          local food3 = display.newImage(mainGroup, "images/food3.png")
          food3:scale(0.7, 0.7)
          physics.addBody(food3, "static", {radius = 70, density = 0, friction = 1, bounce = 0.5})
          food3.myName = "food"
          food3.x = foodXSpawn + foodSpacer * 1.8
          food3.y = 970
          foodXSpawn = foodXSpawn + foodSpacer * 1.3
          foodSpacer = foodSpacer * 1.25
          camera:insert(food1)
          camera:insert(food2)
          camera:insert(food3)
        end

        --------------------------------------------------------------------------------
        -- Enemy Spawns
        --------------------------------------------------------------------------------
        local enemy = {}

        for i = 1, 2000 do
          enemy[i] = display.newImage(mainGroup, "images/enemy1.png")
          enemy[i]:scale(0.5, 0.5)
          physics.addBody(enemy[i], "static", {radius = 50, density = 1, friction = 1, bounce = 2})
          enemy[i].x = 4000 + math.random(display.screenOriginX, display.contentWidth * 200)
          enemy[i].y = -21500 + math.random(display.screenOriginY, display.contentHeight * 18)
          enemy[i].myName = "enemy"
          camera:insert(enemy[i])
        end
        for i = 1, 1500 do
          enemy[i] = display.newImage(mainGroup, "images/hot-air-balloon.png")
          enemy[i]:scale(0.5, 0.5)
          physics.addBody(enemy[i], "static", {radius = 50, density = 1, friction = 1, bounce = 2})
          enemy[i].x = 4000 + math.random(display.screenOriginX, display.contentWidth * 200)
          enemy[i].y = -25500 + math.random(display.screenOriginY, display.contentHeight * 10)
          enemy[i].myName = "enemy"
          camera:insert(enemy[i])
        end

        --------------------------------------------------------------------------------
        -- Obstacle spawns
        --------------------------------------------------------------------------------
        local obstacleXSpawn = 26500
        local obstacleSpacer = 2750


        local obstacle = {}

        for i = 1, 25 do
          local obstacle1 = display.newImage(mainGroup, "images/spikes.png")
          obstacle1:scale(0.5, 0.5)
          physics.addBody(obstacle1, "static", {radius = 90, density = 50, friction = 1, bounce = 0})
          obstacle1.myName = "obstacle"
          obstacle1.x = obstacleXSpawn + obstacleSpacer * 1.2
          obstacle1.y = 970
          obstacleXSpawn = obstacleXSpawn + math.random(500, 500)
          obstacleXSpawn = obstacleXSpawn + obstacleSpacer * 1.4
          obstacleSpacer = obstacleSpacer * 1.1
          camera:insert(obstacle1)
        end

        for i = 1, 50 do
          obstacle[i] = display.newImage(mainGroup, "images/spikeball.png")
          obstacle[i]:scale(0.5, 0.5)
          physics.addBody(obstacle[i], "static", {radius = 50, density = 1, friction = 1, bounce = 2})
          obstacle[i].x = 50000 + math.random(display.screenOriginX, display.contentWidth * 100)
          obstacle[i].y = -19500 + math.random(display.screenOriginY, display.contentHeight * 20)
          obstacle[i].myName = "obstacle"
          camera:insert(obstacle[i])
        end

        for i = 1, 500 do
          obstacle[i] = display.newImage(mainGroup, "images/the_sun.png")
          obstacle[i]:scale(0.5, 0.5)
          physics.addBody(obstacle[i], "static", {radius = 50, density = 1, friction = 1, bounce = 2})
          obstacle[i].x = 50000 + math.random(display.screenOriginX, display.contentWidth * 100)
          obstacle[i].y = -50000 + math.random(display.screenOriginY, display.contentHeight * 20)
          obstacle[i].myName = "obstacle"
          camera:insert(obstacle[i])
        end

        --------------------------------------------------------------------------------
        -- adds UI elements
        --------------------------------------------------------------------------------
        --Debug UI Elements
        foodText = display.newText(uiGroup, "Power: " .. power, display.contentCenterX, 260, native.systemFont, 36)
        foodText:setFillColor(0, 0, 0)
        foodText.alpha = 0

        tapText = display.newText(uiGroup, "Total taps:  " .. tapCount, 500, 80, native.systemFont, 36)
        tapText:setFillColor(0, 0, 0)

        speedText = display.newText(uiGroup, "Power: " .. power, display.contentCenterX, 300, native.systemFont, 36)
        speedText:setFillColor(0, 0, 0)
        speedText.alpha = 0

        distanceText = display.newText(uiGroup, "Total Distance: " .. totalDistance, display.contentCenterX, 340, native.systemFont, 36)
        distanceText:setFillColor(0, 0, 0)
        distanceText.alpha = 0

        scoreText = display.newText(uiGroup, "Score: " .. totalScore - 420, 500, 120, native.systemFont, 36)
        scoreText:setFillColor(0, 0, 0)
        scoreText.alpha = 1

        posText = display.newText(uiGroup, "^ " .. catballY .. " > " .. catballX, 500, 40, native.systemFont, 36)
        posText:setFillColor(0, 0, 0)

        dasbootusesText = display.newText(uiGroup, "x"..dasbootuses, display.contentCenterX + 900, 970, native.systemFont, 36)
        dasbootusesText:setFillColor(0, 0, 0)

        catnipusesText = display.newText(uiGroup, "x"..catnipuses, display.contentCenterX + 900, 850, native.systemFont, 36)
        catnipusesText:setFillColor(0, 0, 0)


        --Clock UI Elements
        clockBG = display.newImageRect(uiGroup, "images/button_blue_dark.png", 900, 800)
        clockBG.x = display.contentCenterX
        clockBG.y = display.contentCenterY - 100
        clockText = display.newText(uiGroup, "5", display.contentCenterX, display.contentCenterY, native.systemFont, 125)
        clockText:setFillColor(1, 1, 1)
        tapWarn = display.newText("TAP NOW!", display.contentCenterX, display.contentCenterY - 200, native.systemFont, 150)
        tapWarn:setFillColor(1, 1, 1)

        gameClockBG = display.newImageRect(uiGroup, "images/white_button_dark.png", 200, 100)
        gameClockBG.x = display.contentCenterX
        gameClockBG.y = 75
        gameClockText = display.newText(uiGroup, secondsGame, display.contentCenterX, 75, native.systemFont, 30)
        gameClockText:setFillColor(0, 0, 0)
      end

      -- show()
      function scene:show(event)
        local sceneGroup = self.view
        local phase = event.phase
        if (phase == "will") then
          -- Code here runs when the scene is still off screen (but is about to come on screen)
        elseif (phase == "did") then
          -- Code here runs when the scene is entirely on screen

          --updates ui elements
          local function updateText()
            foodText.text = "Food Consumed:  " .. foodEaten
            tapText.text = "Total Taps:  " .. tapCount
            speedText.text = "Power: " .. power
            distanceText.text = "Total Distance: " .. totalDistance
            dasbootusesText.text = "x"..dasbootuses
            catnipusesText.text = "x"..catnipuses
            totalScore = math.round((tapCount * 5) + (foodEaten * 500) + (enemiesDefeated * 1000) + (totalDistance / 2))
            scoreText.text = "Score: " .. totalScore
            posText.text = "^ " .. - catballY + 956 .. " > " .. catballX - 420
          end

          --Needed listeners and timers
          timer.performWithDelay(1000, updateTime, secondsLeft)
          timer.performWithDelay(5000, tapperCountdown)
          endGameTimer = timer.performWithDelay(65000, endGame)
          Runtime:addEventListener("tap", rotatecat)
          Runtime:addEventListener("enterFrame", updateText)
          Runtime:addEventListener("enterFrame", moveCamera)
          Runtime:addEventListener("collision", onCollision)
          Runtime:addEventListener("enterFrame", catballPosCalc)
          --------------------------------------------------------------------------------
          -- Camera stuff
          --------------------------------------------------------------------------------
          sceneGroup:insert(camera)
          sceneGroup:insert(mainGroup)
          sceneGroup:insert(backGroup)
          sceneGroup:insert(uiGroup)

          --audio play
          backgroundMusic = audio.loadStream("sound/bgm1.mp3")
          audio.play(backgroundMusic, {channel = 1, loops = -1})
        end
      end

      -- hide()
      function scene:hide(event)
        local sceneGroup = self.view
        local phase = event.phase
        if (phase == "will") then
          -- Code here runs when the scene is on screen (but is about to go off screen)

          --Code to end the level correctly
          physics.stop()
          audio.stop()
          composer.removeScene("game", false)
          Runtime:removeEventListener("enterFrame", moveCamera)
          cat:removeEventListener("touch", cat)
          Runtime:removeEventListener("enterFrame", onEnterFrame)
          Runtime:removeEventListener("tap", rotatecat)
          Runtime:removeEventListener("collision", onCollision)
          Runtime:removeEventListener("enterFrame", updateText)
          Runtime:removeEventListener("enterFrame", catballPosCalc)
          timer.cancel(endGameTimer)
          timer.cancel(gameTimeRemainingTimer)
          gameTimeRemainingTimer = nil
        elseif (phase == "did") then
          -- Code here runs immediately after the scene goes entirely off screen
        end
      end

      -- destroy()
      function scene:destroy(event)
        local sceneGroup = self.view
        -- Code here runs prior to the removal of scene's view
        audio.dispose(backgroundMusic)

        for s, v in pairs(soundTable) do
          audio.dispose(soundTable[s])
          soundTable[s] = nil
        end
      end

      -- -----------------------------------------------------------------------------------
      -- Scene event function listeners
      -- -----------------------------------------------------------------------------------
      scene:addEventListener("create", scene)
      scene:addEventListener("show", scene)
      scene:addEventListener("hide", scene)
      scene:addEventListener("destroy", scene)
      -- -----------------------------------------------------------------------------------

      return scene
