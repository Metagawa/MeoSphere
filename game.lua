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
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local tapCount = 0
local power = 0
local tapTimer
local foodEaten = 0
local catballX = 0
local catballY = 0
local totalDistance = 0
local totalScore = 0
local scoreText
local secondsLeft = 5
local secondsGame = 60
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()
local enemiesDefeated = 0
local backgroundMusic
local nomSound
local duckSound
local oofSound
local hurtSound
local soundTable = {
  nomSound = audio.loadSound("sound/nom.wav"), --https://freesound.org/people/xtrgamr/sounds/253615/
  duckSound = audio.loadSound("sound/quack.wav"), --https://freesound.org/people/crazyduckman/sounds/185549/
  oofSound = audio.loadSound("sound/oof1.mp3"), --http://soundbible.com/free-sound-effects-1.html
  hurtSound = audio.loadSound("sound/hurt1.wav") --http://soundbible.com/free-sound-effects-1.html
}
display.setDefault("background", 72, 209, 204)
display.setDefault("textureWrapX", "repeat")
display.setDefault("textureWrapY", "repeat")

--Camera declarations (sky background)
local x, y = display.contentCenterX, display.contentCenterY
local cam = display.newRect(x, y, 4999999, 4999999)
cam.fill = {type = "image", filename = "images/sky.png"}
cam.fill.scaleX = 0.0007
cam.fill.scaleY = 0.0007

--function declarations

--function to go to main menu
local function gotoMenu()
  composer.gotoScene("menu")
end

--function to go to shop
local function gotoShop()
  composer.setVariable("finalScore", totalScore)
  composer.gotoScene("shop")
end

--function to reset the game
local function resetGame()
  composer.gotoScene("tips")
end

--function to end the game
local function endGame()
  physics.stop()
  composer.gotoScene("shop")
  timer.cancel(endGameTimer)
end

--this rotates the cat and shoots him to the right with increasing strength the more taps have occurred
local function rotatecat()
  tapCount = tapCount + 1
  local tapText = tapCount
  cat:applyForce(power, -power, cat.x, cat.y)
  cat:applyAngularImpulse(500)
  power = power + math.round(tapCount + totalDistance / 1000) + foodEaten * 100 + enemiesDefeated * 10
end

--onscreen clock codes
local function updateTime()
  secondsLeft = secondsLeft - 1
  local timeDisplay = string.format("00:%02d", secondsLeft)
  clockText.text = timeDisplay
  if (secondsLeft == 0) then
    clockText.alpha = 0
    clockBG.alpha = 0
    tapWarn.alpha = 0
  end
end

local function gameTimeRemaining(event)
  secondsGame = secondsGame - 1
  local minutes = math.floor(secondsGame / 60)
  local seconds = secondsGame % 60
  local gameTimeDisplay = string.format("%02d:%02d", minutes, secondsGame)
  gameClockText.text = gameTimeDisplay
  if (secondsGame == 0) then
    gameClockText.alpha = 0
    gameClockBG.alpha = 0
  end
end

--prevents cat from moving before ten seconds have passed
local function tapperCountdown(event)
  physics.start()
  Runtime:removeEventListener("tap", rotatecat)
  lsButton:addEventListener("tap", gotoMenu)
  shopButton:addEventListener("tap", gotoShop)
  resetButton:addEventListener("tap", resetGame)
  gameTimeRemainingTimer = timer.performWithDelay(1000, gameTimeRemaining, secondsGame)
end

--------------------------------------------------------------------------------
--Collision
--------------------------------------------------------------------------------
--Adds collision rules to erase food when it contacts Catball and alter velocity, also removes enemies on contact
function onCollision(event)
  CBx, CBy = cat:getLinearVelocity()
  if (event.phase == "began") then
    if
      event.object1.myName == "Catball" and event.object2.myName == "food" or
        event.object1.myName == "food" and event.object2.myName == "Catball"
     then
      foodEaten = foodEaten + 1
      cat:setLinearVelocity(CBx + CBy * 1.5 + 1500, -CBy * 2 - power - 2200)
      event.contact.isEnabled = false
      event.object2:removeSelf()
      event.object2 = nil
      audio.play(soundTable["nomSound"])
    elseif
      event.object1.myName == "Catball" and event.object2.myName == "enemy" or
        event.object1.myName == "enemy" and event.object2.myName == "Catball"
     then
      enemiesDefeated = enemiesDefeated + 1
      cat:setLinearVelocity(CBx + 3000, CBy - 5000)
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

  --Button display code
  lsButton = display.newImageRect(uiGroup, "images/white_button_dark.png", 300, 100)
  lsButton.x = display.contentCenterX + 700
  lsButton.y = 100
  lsButtonText = display.newText(uiGroup, "Main Menu", display.contentCenterX + 700, 100, native.systemFont, 35)
  lsButtonText:setFillColor(0, 0, 0)

  shopButton = display.newImageRect(uiGroup, "images/white_button_dark.png", 300, 100)
  shopButton.x = display.contentCenterX + 700
  shopButton.y = 250
  shopButtonText = display.newText(uiGroup, "Visit the Shop", display.contentCenterX + 700, 250, native.systemFont, 35)
  shopButtonText:setFillColor(0, 0, 0)

  resetButton = display.newImageRect(uiGroup, "images/white_button_dark.png", 300, 100)
  resetButton.x = display.contentCenterX + 700
  resetButton.y = 400
  resetButtonText = display.newText(uiGroup, "Reset", display.contentCenterX + 700, 400, native.systemFont, 35)
  resetButtonText:setFillColor(0, 0, 0)

  --adds a circle and skins a cat onto it
  cat = display.newImage(mainGroup, "images/cat.png", 500, 500)
  cat:scale(0.15, 0.15)
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
    totalDistance = catballX - 420
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
  physics.addBody(floor, "static", {friction = 1.0, bounce = -1})
  floor.myName = "floor"

  local wall = display.newRect(0, 600, 1, 500000)
  wall.x, wall.y = 0, 1080
  physics.addBody(wall, "static", {friction = 1.5, bounce = 0.5})

  camera:insert(floor)

  --------------------------------------------------------------------------------
  -- Food Spawns
  --------------------------------------------------------------------------------
  --foodXSpawn set to 1000 pixels
  local foodXSpawn = 650
  local foodSpacer = 750
  --food spawned for 500 of each item over an increasing distance.
  local food = {}
  for i = 1, 500 do
    local food1 = display.newImage(mainGroup, "images/food1.png")
    food1:scale(0.3, 0.3)
    physics.addBody(food1, "static", {radius = 65, density = 0, friction = 1, bounce = 0.5})
    food1.myName = "food"
    food1.x = foodXSpawn + foodSpacer * 1.2
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
    food3:scale(0.47, 0.47)
    physics.addBody(food3, "static", {radius = 70, density = 0, friction = 1, bounce = 0.5})
    food3.myName = "food"
    food3.x = foodXSpawn + foodSpacer * 1.8
    food3.y = 970
    foodXSpawn = foodXSpawn + foodSpacer * 1.4
    foodSpacer = foodSpacer * 1.1
    camera:insert(food1)
    camera:insert(food2)
    camera:insert(food3)
  end

  --------------------------------------------------------------------------------
  -- Enemy Spawns
  --------------------------------------------------------------------------------
  local enemy = {}

  for i = 1, 250 do
    enemy[i] = display.newImage(mainGroup, "images/enemy1.png")
    enemy[i]:scale(0.5, 0.5)
    physics.addBody(enemy[i], "static", {radius = 50, density = 1, friction = 1, bounce = 2})
    enemy[i].x = 4000 + math.random(display.screenOriginX, display.contentWidth * 100)
    enemy[i].y = -7500 + math.random(display.screenOriginY, display.contentHeight * 7)
    enemy[i].myName = "enemy"
    camera:insert(enemy[i])
  end

  --------------------------------------------------------------------------------
  -- Obstacle spawns
  --------------------------------------------------------------------------------
  local obstacleXSpawn = 2650
  local obstacleSpacer = 2750

  local obstacle = {}

  for i = 1, 25 do
    local obstacle1 = display.newImage(mainGroup, "images/spikes.png")
    obstacle1:scale(0.5, 0.5)
    physics.addBody(obstacle1, "static", {radius = 90, density = 50, friction = 1, bounce = 0})
    obstacle1.myName = "obstacle"
    obstacle1.x = obstacleXSpawn + obstacleSpacer * 1.2
    obstacle1.y = 970
    obstacleXSpawn = obstacleXSpawn + 600
    obstacleXSpawn = obstacleXSpawn + obstacleSpacer * 1.4
    obstacleSpacer = obstacleSpacer * 1.1
    camera:insert(obstacle1)
  end

  --------------------------------------------------------------------------------
  -- adds UI elements
  --------------------------------------------------------------------------------
  --Debug UI Elements
  foodText = display.newText(uiGroup, "Power: " .. power, 1200, 80, native.systemFont, 36)
  foodText:setFillColor(0, 0, 0)

  tapText = display.newText(uiGroup, "Total taps:  " .. tapCount, 1200, 120, native.systemFont, 36)
  tapText:setFillColor(0, 0, 0)

  speedText = display.newText(uiGroup, "Power: " .. power, 1200, 160, native.systemFont, 36)
  speedText:setFillColor(0, 0, 0)

  distanceText = display.newText(uiGroup, "Total Distance: " .. totalDistance - 420, 1200, 200, native.systemFont, 36)
  distanceText:setFillColor(0, 0, 0)

  scoreText = display.newText(uiGroup, "Score: " .. totalScore - 420, 1200, 240, native.systemFont, 36)
  scoreText:setFillColor(0, 0, 0)

  posText = display.newText(uiGroup, "^ " .. catballY .. " > " .. catballX, 500, 80, native.systemFont, 36)
  posText:setFillColor(0, 0, 0)

  --Clock UI Elements
  clockBG = display.newImageRect(uiGroup, "images/red_button.png", 200, 200)
  clockBG.x = 1800
  clockBG.y = 950
  clockText = display.newText(uiGroup, "00:05", 1800, 1000, native.systemFont, 60)
  clockText:setFillColor(1, 1, 1)
  tapWarn = display.newText("TAP", 1800, 920, native.systemFont, 75)
  tapWarn:setFillColor(1, 1, 1)

  gameClockBG = display.newImageRect(uiGroup, "images/white_button_dark.png", 200, 50)
  gameClockBG.x = display.contentCenterX
  gameClockBG.y = 75
  gameClockText = display.newText(uiGroup, "01:00", display.contentCenterX, 75, native.systemFont, 30)
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
      totalScore = math.round(((power - tapCount * 5) + (foodEaten * 500) + math.round(totalDistance / 5) / 2))
      scoreText.text = "Score: " .. totalScore
      posText.text = "^ " .. -catballY + 956 .. " > " .. catballX - 420
    end

    --Needed listeners and timers
    timer.performWithDelay(1000, updateTime, secondsLeft)
    timer.performWithDelay(5000, tapperCountdown)
    endGameTimer = timer.performWithDelay(60000, endGame)
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
