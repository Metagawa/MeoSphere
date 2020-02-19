

-- include Corona's "physics" library and Perspective.lua

--physics stuff
local physics = require "physics"
physics.start()
physics.setGravity( 0, 9.8)
<<<<<<< HEAD
physics.setScale( 80 )
=======
physics.setScale( 100 )
>>>>>>> 158bf0fb35cb692e65eac6d34f4b0690445968f3
physics.setDrawMode( "normal" )


--camera stuff
local perspective = require("perspective")
local function forcesByAngle(totalForce, angle) local forces = {} local radians = -math.rad(angle) forces.x = math.cos(radians) * totalForce forces.y = math.sin(radians) * totalForce return forces end
local camera = perspective.createView()


-- forward declarations and other locals
math.randomseed( os.time())
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local tapCount = 0
local tapSpeed = 500
local tapTimer
local score = 0 --Food eaten score - (tapCount * amount of food eaten)
local scoreText
local foodEaten = 0
local foodTable = {"food1", "food2", "food3"}
local randNum = math.random
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

--Background stuff
local background = display.newImageRect( backGroup, "background1.png", 1940, 1080 )
background.X = display.contentCenterX
background.Y = display.contentCenterY
background.anchorX = 0.01
background.anchorY = 0.01

--adds a circle and skins a cat onto it
local cat = display.newImage( mainGroup, "cat.png", 500, 500 ) cat:scale( 0.2, 0.2)
cat.x = display.actualContentWidth - 1500
cat.y = display.actualContentHeight - 100
--adds physics to Catball and gives him circle physics.
physics.addBody( cat, { radius = 85, density = 1.0, friction = 0.5, bounce = 0.5} )
cat.myName = "Catball"
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

--this rotates the cat and shoots him to the right with increasing strength the more taps have occurred
local function rotatecat()
  tapCount = tapCount + 1
  local tapText = tapCount
  cat:applyForce(tapSpeed, -150, cat.x, cat.y)
  cat:applyAngularImpulse(500)
  tapSpeed = 500 + tapCount * 5
end
Runtime:addEventListener( "tap", rotatecat)

--adds UI elements
foodText = display.newText( uiGroup, "Power: " .. tapSpeed, 1500, 80, native.systemFont, 36)
foodText:setFillColor( 0, 0, 0 )
tapText = display.newText( uiGroup, "Total taps:  " .. tapCount, 1500, 120, native.systemFont, 36 )
tapText:setFillColor( 0, 0, 0 )
speedText = display.newText( uiGroup, "Power: " .. tapSpeed, 1500, 160, native.systemFont, 36)
speedText:setFillColor( 0, 0, 0 )
--updates ui elements
local function updateText()
  foodText.text = "Food Consumed:  " .. foodEaten
  tapText.text = "Total taps:  " .. tapCount
  speedText.text = "Power: "..tapSpeed
end
Runtime:addEventListener( "enterFrame", updateText)

--tracks Catball's position at all times.
local catballX, catballY
local function onEnterFrame( event )
  catballX = cat.x
  catballY = cat.y
end
Runtime:addEventListener( "enterFrame", onEnterFrame)

--foodXSpawn set to 1000 pixels
local foodXSpawn = 1000
--food spawned contnuosly every 300 pixels, this continues infinitely but the camera doesn't follow Catball
local function spawnFood( event )
  if catballX > 540 then
    local food = display.newImage( mainGroup, "food1.png", foodXSpawn, 1000 ) food:scale( 0.2, 0.2)
<<<<<<< HEAD
    physics.addBody( food,  { radius = 30, density = 0.2, friction = 0.5, bounce = 0.5} )
=======
    physics.addBody( food,  { radius = 30, density = 1.0, friction = 0.5, bounce = 0.5} )
>>>>>>> 158bf0fb35cb692e65eac6d34f4b0690445968f3
    food.myName = "food"
    local food = display.newImage( mainGroup, "food2.png", foodXSpawn + 300, 1000 ) food:scale( 0.5, 0.5)
    physics.addBody( food, { radius = 70, density = 0.4, friction = 0.5, bounce = 1.5} )
    food.myName = "food"
    local food = display.newImage( mainGroup, "food3.png", foodXSpawn + 600, 1000 ) food:scale( 0.2, 0.2)
    physics.addBody( food, { radius = 30, density = 0.2, friction = 0.5, bounce = 0.5} )
    food.myName = "food"
    foodXSpawn = foodXSpawn + 900


--secondary condition to spawn food, not needed currently, might be removed.
  --elseif catballx == 540 then
    --local food = display.newImage( mainGroup, "food1.png", foodXSpawn, 1000 ) food:scale( 0.2, 0.2)
    --physics.addBody( food, { radius = 30, density = 1.0, friction = 0.5, bounce = 0.5} )
    --food.myName = "food"
    --local food = display.newImage( mainGroup, "food2.png", foodXSpawn + 300, 1000 ) food:scale( 0.2, 0.2)
    --physics.addBody( food, { radius = 30, density = 1.0, friction = 0.5, bounce = 0.5} )
    --food.myName = "food"
    --local food = display.newImage( mainGroup, "food3.png", foodXSpawn + 600, 1000 ) food:scale( 0.2, 0.2)
    --physics.addBody( food, { radius = 30, density = 1.0, friction = 0.5, bounce = 0.5} )
    --food.myName = "food"
    --foodXSpawn = foodXSpawn + 900
  end
end
Runtime:addEventListener( "enterFrame", spawnFood)

--Adds collision rules to erase food when it contacts Catball, increments foodEaten by 1
function onCollision( event )
  if (event.phase == "began" ) then
    if event.object1.myName == "food" and event.object2.myName == "Catball" then
      foodEaten = foodEaten + 1
      event.object1:removeSelf()
      event.object1 = nil
    elseif event.object1.myName == "Catball" and event.object2.myName == "food" then
      foodEaten = foodEaten + 1
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
physics.addBody( floor, "static", { friction = 0.5, shape = floorShape, bounce = 0.2 } )

--debug stuff
--adds ceiling
local wall = display.newRect(0, 0, 500000, 50 )
physics.addBody( wall, "static", { friction = 0.5, bounce = 0.2 } )
--adds walls
--left wall
local wall = display.newRect( 0, 500, 50, 500000 )
wall.x, wall.y = 0, 1080
physics.addBody( wall, "static", { friction = 0.5, bounce = 0.2 } )
--right wall
local wall = display.newRect( 1920, 0, 50, 500000 )
physics.addBody( wall, "static", { friction = 0.5, bounce = 0.2 } )
