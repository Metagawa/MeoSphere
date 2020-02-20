

-- include Corona's "physics" library and Perspective.lua

--physics stuff
local physics = require "physics"
physics.start()
physics.pause()
physics.setGravity( 0, 9.8)
physics.setScale( 80 )
physics.setDrawMode( "normal" )
math.randomseed(os.time( ))


-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local tapCount = 0
local tapSpeed = 500
local tapTimer
--Food eaten score - (tapCount * amount of food eaten)
local scoreText
local foodEaten = 0
local foodTable = {"food1", "food2", "food3"}
local randNum = math.random(1920)
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

--------------------------------------------------------------------------------
-- Camera stuff
--------------------------------------------------------------------------------

local require = require

local perspective = require("perspective")

local function forcesByAngle(totalForce, angle) local forces = {} local radians = -math.rad(angle) forces.x = math.cos(radians) * totalForce forces.y = math.sin(radians) * totalForce return forces end

--------------------------------------------------------------------------------
-- Build Camera
--------------------------------------------------------------------------------
local camera = perspective.createView()
--Background stuff
local background = display.newImageRect( backGroup, "background1.png", 1940, 1080 )
background.X = display.contentCenterX
background.Y = display.contentCenterY
background.anchorX = 0.01
background.anchorY = 0.01

--adds a circle and skins a cat onto it
local cat = display.newImage( mainGroup, "cat.png", 500, 500 ) cat:scale( 0.2, 0.2)
cat.x = display.actualContentWidth - 1500
cat.y = display.actualContentHeight - 200
--adds physics to Catball and gives him circle physics.
physics.addBody( cat, { radius = 85, density = 1, friction = 0.5, bounce = 0.4} )
cat.myName = "Catball"
cat.linearDamping = .2
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

--this rotates the cat and shoots him to the right with increasing strength the more taps have occurred
local function rotatecat()
  tapCount = tapCount + 1
  local tapText = tapCount
  cat:applyForce(tapSpeed, -tapSpeed, cat.x, cat.y)
  cat:applyAngularImpulse(500)
  tapSpeed = 500 + tapCount * 5
end
Runtime:addEventListener( "tap", rotatecat)

--prevents cat from moving before ten seconds have passed
local function tapperCountdown( event )
  physics.start()
end
timer.performWithDelay( 10000, tapperCountdown)

--tracks Catball's position at all times.
local catballX, catballY
local function onEnterFrame( event )
  catballX = cat.x
  catballY = cat.y
end
Runtime:addEventListener( "enterFrame", onEnterFrame)

--Adds collision rules to erase food when it contacts Catball, increments foodEaten by 1, intended outcome of Cat hitting food is for him to bounce off to the right at 45 degrees, it doesn't
function onCollision( event )
  if (event.phase == "began" ) then
    if event.object1.myName == "food" and event.object2.myName == "Catball" then
      foodEaten = foodEaten + 1
      event.object1:removeSelf()
      event.object1 = nil
      --local CBx, CBy = event.object2:getLinearVelocity()
      --event.object2:setLinearVelocity( CBx * 3, CBy)
    elseif event.object1.myName == "Catball" and event.object2.myName == "food" then
      foodEaten = foodEaten + 1
      event.object2:removeSelf()
      event.object2 = nil
      --local CBx, CBy = event.object1:getLinearVelocity()
      --event.object1:setLinearVelocity( CBx * 3, CBy)
    end
  end
end
Runtime:addEventListener( "collision", onCollision)



--adds a floor.
local floor = display.newRect(0, 0, 500000, 50 )
floor.anchorX = 0
floor.anchorY = 1
floor.x, floor.y = 0, 1080
physics.addBody( floor, "static", { friction = 0, shape = floorShape, bounce = 0.4 } )

--debug stuff
--adds ceiling
local ceiling = display.newRect(0, - 6000, 500000, 50 )
physics.addBody( ceiling, "static", { friction = 10, bounce = 0.4 } )
--adds walls
--left wall
local wall = display.newRect( 0, 500, 50, 500000 )
wall.x, wall.y = 0, 1080
physics.addBody( wall, "static", { friction = 10, bounce = 0.4 } )
--right wall
local wall2 = display.newRect( 20000, 0, 50, 500000 )
physics.addBody( wall2, "static", { friction = 10, bounce = 0.4 } )


--------------------------------------------------------------------------------
-- adds UI elements
--------------------------------------------------------------------------------

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
  speedText.text = "Power: ".. tapSpeed
end
Runtime:addEventListener( "enterFrame", updateText)

--------------------------------------------------------------------------------
-- Food Spawns, very messy, needs optimizing
--------------------------------------------------------------------------------
local food1 = {}
local food2 = {}
local food3 = {}

for i = 1, 333 do
  food1[i] = display.newImage( mainGroup, "food".."1"..".png" ) food1[i]:scale( 0.5, 0.5)
  physics.addBody( food1[i], "static", { radius = 50, density = 0, friction = 0, bounce = .7} )
  food1[i].x = 1000 + math.random(display.screenOriginX, display.contentWidth * 10)
  food1[i].y = -10000 + math.random(display.screenOriginY, display.contentHeight * 10)
  food1[i].myName = "food"

  food2[i] = display.newImage( mainGroup, "food".."2"..".png" ) food2[i]:scale( 0.5, 0.5)
  physics.addBody( food2[i], "static", { radius = 50, density = 0, friction = 0, bounce = .7} )
  food2[i].x = 1000 + math.random(display.screenOriginX, display.contentWidth * 10)
  food2[i].y = -10000 + math.random(display.screenOriginY, display.contentHeight * 10)
  food2[i].myName = "food"

  food3[i] = display.newImage( mainGroup, "food".."3"..".png" ) food3[i]:scale( 0.5, 0.5)
  physics.addBody( food3[i], "static", { radius = 50, density = 0, friction = 0, bounce = .7} )
  food3[i].x = 1000 + math.random(display.screenOriginX, display.contentWidth * 10)
  food3[i].y = -10000 + math.random(display.screenOriginY, display.contentHeight * 10)
  food3[i].myName = "food"

  camera:add(food1[i], 4)
  camera:add(food2[i], 4)
  camera:add(food3[i], 4)

end

--------------------------------------------------------------------------------
-- Camera stuff
--------------------------------------------------------------------------------
camera:add(cat, 1)
camera:add(floor, 1)
camera:add(wall, 1)
camera:add(wall2, 1)
camera:add(ceiling, 1)
camera.damping = 2
camera:setFocus(cat)
camera:track()
uiGroup:toFront()

--Ugrades Below
