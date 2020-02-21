
--------------------------------------------------------------------------------
-- include Corona's "physics" library and Perspective.lua
--------------------------------------------------------------------------------

--physics stuff
local physics = require "physics"
physics.start()
physics.pause()
physics.setGravity( 0, 22)
physics.setScale( 80 )
physics.setDrawMode( "normal" )
math.randomseed(os.time( ))


-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local tapCount = 0
local power = 0
local tapTimer
local foodEaten = 0
local foodTable = {"food1", "food2", "food3"}
local randNum = math.random(1920)
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()
local catballX = 0
local catballY = 0
local totalDistance = 0
local totalScore = 0
local scoreText
display.setDefault( "background", 72, 209, 204 )
display.setDefault( "textureWrapX", "repeat" )
display.setDefault( "textureWrapY", "repeat" )

local x, y = display.contentCenterX, display.contentCenterY
local o = display.newRect( x, y, 9999999, 9999999 )
o.fill = { type = "image", filename = "images/background2.png" }
o.fill.scaleX = 0.00025
o.fill.scaleY = 0.000138

--------------------------------------------------------------------------------
-- Camera stuff
--------------------------------------------------------------------------------

--local require = require

--local perspective = require("perspective")

--local function forcesByAngle(totalForce, angle) local forces = {} local radians = -math.rad(angle) forces.x = math.cos(radians) * totalForce forces.y = math.sin(radians) * totalForce return forces end
--local camera = perspective.createView()



-- Create master display group (for global "camera" scrolling effect)
local game = display.newGroup();
game.x = 0
game:insert( o )
------------------------------------------------------------
-- X-Axis looping background
------------------------------------------------------------
bgDistanceX = 1080
bgDistanceY = 700
for i = 1, 1000 do
  sky = display.newImage( "images/background1.png", bgDistanceX, 700, true )
  bgDistanceX = bgDistanceX + 2365
  game:insert( sky )
end



local grass = display.newImage( "images/food2.png", 160, 440, true )
game:insert( grass )

physics.addBody( grass, "static", { friction = 0.5, bounce = 0.3 } )

local grass2 = display.newImage( "images/food2.png", 1120, 440, true )
game:insert( grass2 )

physics.addBody( grass2, "static", { friction = 0.5, bounce = 0.3 } )

local arrow = display.newImage( "images/food3.png", 50, 120 )
game:insert( arrow );

-- Camera follows bolder automatically
local function moveCamera()
  if (cat.x > 80 or cat.y > 0 )then
    game.x = -cat.x + 250
    game.y = -cat.y + 800
  end
end
Runtime:addEventListener( "enterFrame", moveCamera )


--Background stuff

--local background = display.newImageRect( backGroup, "images/background1.png", 1940, 1080 )
--background.X = display.contentCenterX
--background.Y = display.contentCenterY
--background.anchorX = 0
--background.anchorY = 0

--adds a circle and skins a cat onto it
cat = display.newImage( mainGroup, "images/cat.png", 500, 500 ) cat:scale( 0.2, 0.2)
cat.bodyType = "kinematic"
game:insert( cat )

cat.x = display.actualContentWidth - 1500
cat.y = display.actualContentHeight - 200
--adds physics to Catball and gives him circle physics.
physics.addBody( cat, { radius = 85, density = 1, friction = 0.5, bounce = .6} )
cat.myName = "Catball"
cat.linearDamping = .5
cat.angularDamping = .2

--makes the cat draggable, pauses physics while being dragged
function cat:touch( event )
  if event.phase == "began" then
    physics.pause()
    self.markX = self.x -- store x location of object
    self.markY = self.y -- store y location of object
  elseif event.phase == "moved" then
    local x = (event.x - event.xStart) + self.markX
    local y = (event.y - event.yStart) + self.markY
    self.x, self.y = x, y -- move object based on calculations above
  elseif event.phase == "ended" then
    physics.start()
  end
  return true
end

-- add the event listener to the circle
cat:addEventListener( "touch", cat )

--tracks Catball's position at all times.
function onEnterFrame( event )
  catballX = cat.x
  catballY = cat.y

  --ui calculations--
  totalDistance = math.round(catballX / 100) - 4

  --ui calculations end--
end
Runtime:addEventListener( "enterFrame", onEnterFrame)
local enemiesDefeated = 0

--this rotates the cat and shoots him to the right with increasing strength the more taps have occurred
local function rotatecat()
  tapCount = tapCount + 1
  local tapText = tapCount
  cat:applyForce(power, - power, cat.x, cat.y)
  cat:applyAngularImpulse(500)
  power = power + math.round(tapCount / 2 + totalDistance / 1000)
end
Runtime:addEventListener( "tap", rotatecat)

--prevents cat from moving before ten seconds have passed
local function tapperCountdown( event )
  physics.start()
end
timer.performWithDelay( 5000, tapperCountdown)


--Adds collision rules to erase food when it contacts Catball, increments foodEaten by 1, intended outcome of Cat hitting food is for him to bounce off to the right at 45 degrees, it doesn't
function onCollision( event )
  if (event.phase == "began" ) then

    if event.object1.myName == "Catball" and event.object2.myName == "food" then
      foodEaten = foodEaten + 1
      CBx, CBy = event.object1:getLinearVelocity()
      event.object1:setLinearVelocity( CBx + 1200, - power - 2200)
      event.contact.isEnabled = false
      power = power + 10
      event.object2:removeSelf()
      event.object2 = nil

    elseif event.object1.myName == "Catball" and event.object2.myName == "enemy" then
      enemiesDefeated = enemiesDefeated + 1
      CBx, CBy = event.object1:getLinearVelocity()
      event.object1:setLinearVelocity( CBx + 2500, CBy - 5000)
      event.contact.isEnabled = false
      power = power + 500
      event.object2:removeSelf()
      event.object2 = nil
    end
  end
end

Runtime:addEventListener( "collision", onCollision)


--adds a floor.
local floor = display.newRect(0, 0, 500000, 50 )
floor.anchorX = 0
floor.anchorY = 1
floor.x, floor.y = 0, 1080
physics.addBody( floor, "static", { friction = 2.5, shape = floorShape, bounce = 00 } )
game:insert(floor)
--debug stuff
--adds ceiling
--local ceiling = display.newRect(0, - 6000, 500000, 50 )
--physics.addBody( ceiling, "static", { friction = 1., bounce = 0.5 } )
--adds walls
--left wall
local wall = display.newRect( 0, 500, 50, 500000 )
wall.x, wall.y = 0, 1080
physics.addBody( wall, "static", { friction = 1.5, bounce = 0.5 } )
--right wall
--local wall2 = display.newRect( 20000, 0, 50, 500000 )
--physics.addBody( wall2, "static", { friction = 1.5, bounce = 0.5 } )


--------------------------------------------------------------------------------
-- adds UI elements
--------------------------------------------------------------------------------


foodText = display.newText( uiGroup, "Power: " .. power, 1500, 80, native.systemFont, 36)
foodText:setFillColor( 0, 0, 0 )
tapText = display.newText( uiGroup, "Total taps:  " .. tapCount, 1500, 120, native.systemFont, 36 )
tapText:setFillColor( 0, 0, 0 )
speedText = display.newText( uiGroup, "Power: " .. power, 1500, 160, native.systemFont, 36)
speedText:setFillColor( 0, 0, 0 )
distanceText = display.newText( uiGroup, "Total Distance: " .. totalDistance - 420, 1500, 200, native.systemFont, 36)
distanceText:setFillColor( 0, 0, 0 )
scoreText = display.newText( uiGroup, "Score: " .. totalScore - 420, 1500, 240, native.systemFont, 36)
scoreText:setFillColor( 0, 0, 0 )
--updates ui elements
local function updateText()
  foodText.text = "Food Consumed:  " .. foodEaten
  tapText.text = "Total Taps:  " .. tapCount
  speedText.text = "Power: ".. power
  distanceText.text = "Total Distance: " .. totalDistance
  totalScore = ((power - tapCount * 5) + (foodEaten * 500) + (totalDistance * 10) / 2)
  scoreText.text = "Score: "..totalScore

end
Runtime:addEventListener( "enterFrame", updateText)

--------------------------------------------------------------------------------
-- Food Spawns, very messy, needs optimizing
--------------------------------------------------------------------------------


--foodXSpawn set to 1000 pixels
local foodXSpawn = 650
local foodSpacer = 750

--food spawned contnuosly every 300 pixels, this continues infinitely but the camera doesn't follow Catball
local food = {}
for i = 1, 500 do
  local food1 = display.newImage( mainGroup, "images/food1.png", foodXSpawn + foodSpacer * 1.2, 985 ) food1:scale( 0.3, 0.3)
  physics.addBody( food1, "static", { radius = 65, density = 0, friction = 1, bounce = 0.5} )
  food1.myName = "food"
  foodXSpawn = foodXSpawn + 600
  local food2 = display.newImage( mainGroup, "images/food2.png", foodXSpawn + foodSpacer * 1.6, 960 ) food2:scale( 0.5, 0.5)
  physics.addBody( food2, "static", { radius = 90, density = 0, friction = 1, bounce = 0.5} )
  food2.myName = "food"
  foodXSpawn = foodXSpawn + 600
  local food3 = display.newImage( mainGroup, "images/food3.png", foodXSpawn + foodSpacer * 1.8, 970 ) food3:scale( 1, 1)
  physics.addBody( food3, "static", { radius = 65, density = 0, friction = 1, bounce = 0.5} )
  food3.myName = "food"
  foodXSpawn = foodXSpawn + foodSpacer * 1.4
  foodSpacer = foodSpacer * 1.1
  --camera:add(food1, 4)
  --camera:add(food2, 4)
  --camera:add(food3, 4)
  game:insert(food1)
  game:insert(food2)
  game:insert(food3)
end


--------------------------------------------------------------------------------
-- Enemy Spawns
--------------------------------------------------------------------------------


local enemy = {}


for i = 1, 1000 do
  enemy[i] = display.newImage( mainGroup, "images/enemy1.png" ) enemy[i]:scale( 0.5, 0.5)
  physics.addBody( enemy[i], "static", { radius = 50, density = 1, friction = 1, bounce = 2} )
  enemy[i].x = 5000 + math.random(display.screenOriginX, display.contentWidth * 100)
  enemy[i].y = -8500 + math.random(display.screenOriginY, display.contentHeight * 7)
  enemy[i].myName = "enemy"
  --camera:add(enemy[i], 4)
  game:insert(enemy[i])
end


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

--------------------------------------------------------------------------------
-- Camera stuff
--------------------------------------------------------------------------------

--camera:add(cat, 1)
--camera:add(floor, 1)
--camera:add(wall, 1)
--camera:add(wall2, 1)
--camera:add(ceiling, 1)
--camera.damping = 2
--camera:setFocus(cat)
--camera:track()
uiGroup:toFront()



--Ugrades Below
--3 Different cats (Vary statistics)
--click upgrades
--Special food spawn (Once purchased in shop will spawn a high value food in all levels)
