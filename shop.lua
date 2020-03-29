local composer = require("composer")

local scene = composer.newScene()

audio.reserveChannels(1)
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables

--High Score code obtained and altered from Corona Guide https://docs.coronalabs.com/guide/programming/06/index.html
local json = require("json")

local scoresTable = {}

local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)

local function loadScores()
  local file = io.open(filePath, "r")

  if file then
    local contents = file:read("*a")
    io.close(file)
    scoresTable = json.decode(contents)
  end

  if (scoresTable == nil or #scoresTable == 0) then
    scoresTable = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  end
end

local function saveScores()
  for i = #scoresTable, 11, - 1 do
    table.remove(scoresTable, i)
  end

  local file = io.open(filePath, "w")

  if file then
    file:write(json.encode(scoresTable))
    io.close(file)
  end
end
--End of Corona Guide Code

local shopBackgroundMusic
local uiGroup = display.newGroup()

local function gotoMenu()
  composer.gotoScene("menu", {time = 800, effect = "crossFade"})
end
local function gotoLS()
  composer.gotoScene("game")
  local backgroundMusic = audio.loadStream("sound/bgm1.mp3")

  local backgroundMusicChannel = audio.play(backgroundMusic, {channel = 1, loops = -1, fadein = 10000})
end
nopeSound = audio.loadSound("sound/nope.mp3")

local function addUpgrade1()
  if (carriedScore >= 500) then
    carriedScore = carriedScore - 500
    upgrade1 = true
    upgrade1Bought = true
    upgradeBtn1.alpha = 0.5
    upgradeBtn1:removeEventListener("tap", addUpgrade1)
  else
    audio.play(nopeSound)
  end
end

local function addUpgrade2()
  if (carriedScore >= 15000) then
    carriedScore = carriedScore - 15000
    upgrade2 = true
    upgrade2Bought = true
    upgrade1 = false
    upgradeBtn2.alpha = 0.5
    upgradeBtn1.alpha = 0.5
    upgradeBtn2:removeEventListener("tap", addUpgrade2)
    upgradeBtn1:removeEventListener("tap", addUpgrade1)
  else
    audio.play(nopeSound)
  end
end

local function addUpgrade3()
  if (carriedScore >= 45000) then
    carriedScore = carriedScore - 45000
    upgrade3 = true
    upgrade3Bought = true
    upgrade2 = false
    upgradeBtn3.alpha = 0.5
    upgradeBtn2.alpha = 0.5
    upgradeBtn1.alpha = 0.5
    upgradeBtn3:removeEventListener("tap", addUpgrade3)
    upgradeBtn2:removeEventListener("tap", addUpgrade2)
    upgradeBtn1:removeEventListener("tap", addUpgrade1)
  else
    audio.play(nopeSound)
  end
end

local function addUpgrade4()
  if (carriedScore >= 5000) then
    carriedScore = carriedScore - 5000
    upgrade4 = true
    upgrade4Bought = true
    upgradeBtn4.alpha = 0.5
    upgradeBtn4:removeEventListener("tap", addUpgrade4)
  else
    audio.play(nopeSound)
  end
end

local function addUpgrade5()
  if (carriedScore >= 20000) then
    carriedScore = carriedScore - 20000
    upgrade5 = true
    upgrade5Bought = true
    upgrade4 = false
    upgradeBtn5.alpha = 0.5
    upgradeBtn4.alpha = 0.5
    upgradeBtn5:removeEventListener("tap", addUpgrade5)
    upgradeBtn4:removeEventListener("tap", addUpgrade4)
  else
    audio.play(nopeSound)
  end
end

local function addUpgrade6()
  if (carriedScore >= 50000) then
    carriedScore = carriedScore - 50000
    upgrade6 = true
    upgrade6Bought = true
    upgrade5 = false
    upgradeBtn6.alpha = 0.5
    upgradeBtn5.alpha = 0.5
    upgradeBtn4.alpha = 0.5
    upgradeBtn6:removeEventListener("tap", addUpgrade6)
    upgradeBtn5:removeEventListener("tap", addUpgrade5)
    upgradeBtn4:removeEventListener("tap", addUpgrade4)
  else
    audio.play(nopeSound)
  end
end

local function addUpgrade7()
  if (carriedScore >= 10000) then
    carriedScore = carriedScore - 10000
    upgrade7 = true
    upgrade7Bought = true
    upgradeBtn7.alpha = 0.5
    upgradeBtn7:removeEventListener("tap", addUpgrade7)
  else
    audio.play(nopeSound)
  end
end

local function addUpgrade8()
  if (carriedScore >= 25000) then
    carriedScore = carriedScore - 25000
    upgrade8 = true
    upgrade8Bought = true
    upgrade7 = false
    upgradeBtn8.alpha = 0.5
    upgradeBtn7.alpha = 0.5
    upgradeBtn8:removeEventListener("tap", addUpgrade8)
    upgradeBtn7:removeEventListener("tap", addUpgrade7)
  else
    audio.play(nopeSound)
  end
end

local function addUpgrade9()
  if (carriedScore >= 75000) then
    carriedScore = carriedScore - 75000
    upgrade9 = true
    upgrade9Bought = true
    upgrade8 = false
    upgradeBtn9.alpha = 0.5
    upgradeBtn8.alpha = 0.5
    upgradeBtn7.alpha = 0.5
    upgradeBtn9:removeEventListener("tap", addUpgrade9)
    upgradeBtn8:removeEventListener("tap", addUpgrade8)
    upgradeBtn7:removeEventListener("tap", addUpgrade7)
  else
    audio.play(nopeSound)
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local background = display.newImageRect(sceneGroup, "images/shopBG.png", 1920, 1080)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local upgradeBtn1Text = 
  display.newText(
    sceneGroup,
    "500",
    display.contentCenterX - 750,
    display.contentCenterY - 200,
    native.systemFont,
    44
  )
  upgradeBtn1Text:setFillColor(0, 0, 0)

  upgradeBtn1 = display.newImageRect(uiGroup, "images/upg-clickboost1.png", 125, 125)
  upgradeBtn1.x = display.contentCenterX - 620
  upgradeBtn1.y = display.contentCenterY - 200

  local upgradeBtn2Text = 
  display.newText(
    sceneGroup,
    "15000",
    display.contentCenterX - 750,
    display.contentCenterY - 50,
    native.systemFont,
    44
  )
  upgradeBtn2Text:setFillColor(0, 0, 0)
  upgradeBtn2 = display.newImageRect(uiGroup, "images/upg-clickboost2.png", 125, 125)
  upgradeBtn2.x = display.contentCenterX - 620
  upgradeBtn2.y = display.contentCenterY - 50

  local upgradeBtn3Text = 
  display.newText(
    sceneGroup,
    "45000",
    display.contentCenterX - 750,
    display.contentCenterY + 100,
    native.systemFont,
    44
  )
  upgradeBtn3Text:setFillColor(0, 0, 0)
  upgradeBtn3 = display.newImageRect(uiGroup, "images/upg-clickboost3.png", 125, 125)
  upgradeBtn3.x = display.contentCenterX - 620
  upgradeBtn3.y = display.contentCenterY + 100

  local upgradeBtn4Text = 
  display.newText(
    sceneGroup,
    "5000",
    display.contentCenterX - 470,
    display.contentCenterY - 200,
    native.systemFont,
    44
  )
  upgradeBtn4Text:setFillColor(0, 0, 0)
  upgradeBtn4 = display.newImageRect(uiGroup, "images/upg-foodboost1.png", 125, 125)
  upgradeBtn4.x = display.contentCenterX - 320
  upgradeBtn4.y = display.contentCenterY - 200

  local upgradeBtn5Text = 
  display.newText(
    sceneGroup,
    "20000",
    display.contentCenterX - 470,
    display.contentCenterY - 50,
    native.systemFont,
    44
  )
  upgradeBtn5Text:setFillColor(0, 0, 0)
  upgradeBtn5 = display.newImageRect(uiGroup, "images/upg-foodboost2.png", 125, 125)
  upgradeBtn5.x = display.contentCenterX - 320
  upgradeBtn5.y = display.contentCenterY - 50

  local upgradeBtn6Text = 
  display.newText(
    sceneGroup,
    "50000",
    display.contentCenterX - 470,
    display.contentCenterY + 100,
    native.systemFont,
    44
  )
  upgradeBtn6Text:setFillColor(0, 0, 0)
  upgradeBtn6 = display.newImageRect(uiGroup, "images/upg-foodboost3.png", 125, 125)
  upgradeBtn6.x = display.contentCenterX - 320
  upgradeBtn6.y = display.contentCenterY + 100

  local upgradeBtn7Text = 
  display.newText(
    sceneGroup,
    "10000",
    display.contentCenterX - 175,
    display.contentCenterY - 200,
    native.systemFont,
    44
  )
  upgradeBtn7Text:setFillColor(0, 0, 0)
  upgradeBtn7 = display.newImageRect(uiGroup, "images/upg-scoreboost1.png", 125, 125)
  upgradeBtn7.x = display.contentCenterX - 20
  upgradeBtn7.y = display.contentCenterY - 200

  local upgradeBtn8Text = 
  display.newText(
    sceneGroup,
    "25000",
    display.contentCenterX - 175,
    display.contentCenterY - 50,
    native.systemFont,
    44
  )
  upgradeBtn8Text:setFillColor(0, 0, 0)
  upgradeBtn8 = display.newImageRect(uiGroup, "images/upg-scoreboost2.png", 125, 125)
  upgradeBtn8.x = display.contentCenterX - 20
  upgradeBtn8.y = display.contentCenterY - 50

  local upgradeBtn9Text = 
  display.newText(
    sceneGroup,
    "75000",
    display.contentCenterX - 175,
    display.contentCenterY + 100,
    native.systemFont,
    44
  )
  upgradeBtn9Text:setFillColor(0, 0, 0)
  upgradeBtn9 = display.newImageRect(uiGroup, "images/upg-scoreboost3.png", 125, 125)
  upgradeBtn9.x = display.contentCenterX - 20
  upgradeBtn9.y = display.contentCenterY + 100

  if (upgrade1Bought == true) then
    upgradeBtn1.alpha = 0.5
    upgradeBtn1:removeEventListener("tap", addUpgrade1)
  else
    upgradeBtn1:addEventListener("tap", addUpgrade1)
  end

  if (upgrade2Bought == true) then
    upgradeBtn2.alpha = 0.5
    upgradeBtn1.alpha = 0.5
    upgradeBtn2:removeEventListener("tap", addUpgrade2)
    upgradeBtn1:removeEventListener("tap", addUpgrade1)
  else
    upgradeBtn2:addEventListener("tap", addUpgrade2)
  end

  if (upgrade3Bought == true) then
    upgradeBtn3.alpha = 0.5
    upgradeBtn2.alpha = 0.5
    upgradeBtn1.alpha = 0.5
    upgradeBtn3:removeEventListener("tap", addUpgrade3)
    upgradeBtn2:removeEventListener("tap", addUpgrade2)
    upgradeBtn1:removeEventListener("tap", addUpgrade1)
  else
    upgradeBtn3:addEventListener("tap", addUpgrade3)
  end

  if (upgrade4Bought == true) then
    upgradeBtn4.alpha = 0.5
    upgradeBtn4:removeEventListener("tap", addUpgrade4)
  else
    upgradeBtn4:addEventListener("tap", addUpgrade4)
  end

  if (upgrade5Bought == true) then
    upgradeBtn5.alpha = 0.5
    upgradeBtn4.alpha = 0.5
    upgradeBtn5:removeEventListener("tap", addUpgrade5)
    upgradeBtn4:removeEventListener("tap", addUpgrade4)
  else
    upgradeBtn5:addEventListener("tap", addUpgrade5)
  end

  if (upgrade6Bought == true) then
    upgradeBtn6.alpha = 0.5
    upgradeBtn5.alpha = 0.5
    upgradeBtn4.alpha = 0.5
    upgradeBtn6:removeEventListener("tap", addUpgrade6)
    upgradeBtn5:removeEventListener("tap", addUpgrade5)
    upgradeBtn4:removeEventListener("tap", addUpgrade4)
  else
    upgradeBtn6:addEventListener("tap", addUpgrade6)
  end

  if (upgrade7Bought == true) then
    upgradeBtn7.alpha = 0.5
    upgradeBtn7:removeEventListener("tap", addUpgrade7)
  else
    upgradeBtn7:addEventListener("tap", addUpgrade7)
  end

  if (upgrade8Bought == true) then
    upgradeBtn7.alpha = 0.5
    upgradeBtn8.alpha = 0.5
    upgradeBtn7:removeEventListener("tap", addUpgrade7)
    upgradeBtn8:removeEventListener("tap", addUpgrade8)
  else
    upgradeBtn8:addEventListener("tap", addUpgrade8)
  end

  if (upgrade9Bought == true) then
    upgradeBtn9.alpha = 0.5
    upgradeBtn7.alpha = 0.5
    upgradeBtn8.alpha = 0.5
    upgradeBtn9:removeEventListener("tap", addUpgrade9)
    upgradeBtn7:removeEventListener("tap", addUpgrade7)
    upgradeBtn8:removeEventListener("tap", addUpgrade8)
  else
    upgradeBtn9:addEventListener("tap", addUpgrade9)
  end

  local titleHeader = 
  display.newText(sceneGroup, "Current Total: " .. carriedScore, display.contentCenterX, 50, native.systemFont, 44)
  local function updateTitleHeader()
    titleHeader.text = "Current Total: " .. carriedScore
  end

  Runtime:addEventListener("enterFrame", updateTitleHeader)

  local gameButton = display.newImageRect(sceneGroup, "images/white_button_dark.png", 350, 100)
  gameButton.x = display.contentCenterX - 500
  gameButton.y = 850
  local gameButtonText = 
  display.newText(sceneGroup, "Start the Game", display.contentCenterX - 500, 850, native.systemFont, 44)
  gameButtonText:setFillColor(0, 0, 0)

  local menuButton = display.newImageRect(sceneGroup, "images/white_button_dark.png", 350, 100)
  menuButton.x = display.contentCenterX - 100
  menuButton.y = 850
  local menuButtonText = 
  display.newText(sceneGroup, "Main Menu", display.contentCenterX - 100, 850, native.systemFont, 44)
  menuButtonText:setFillColor(0, 0, 0)

  gameButton:addEventListener("tap", gotoLS)
  menuButton:addEventListener("tap", gotoMenu)

  --High Score code obtained and altered from Corona Guide https://docs.coronalabs.com/guide/programming/06/index.html
  -- Load the previous scores
  loadScores()

  -- Insert the saved score from the last game into the table, then reset it
  table.insert(scoresTable, composer.getVariable("finalScore"))
  composer.setVariable("finalScore", 0)

  -- Sort the table entries
  local function compare(a, b)
    return a > b
  end
  table.sort(scoresTable, compare)

  -- Save scores
  saveScores()

  for i = 1, 10 do
    if (scoresTable[i]) then
      local yPos = 150 + (i * 56)

      local rankNum = 
      display.newText(sceneGroup, i .. ")", display.contentCenterX + 570, yPos + 75, native.systemFont, 45)
      rankNum:setFillColor(0)
      rankNum.anchorX = 1

      local thisScore = 
      display.newText(sceneGroup, scoresTable[i], display.contentCenterX + 600, yPos + 75, native.systemFont, 45)
      thisScore:setFillColor(0)
      thisScore.anchorX = 0
    end
  end
  --End of Corona guide code

  shopBackgroundMusic = audio.loadSound("sound/bgm2.mp3")

  sceneGroup:insert(uiGroup)
end
-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen

    audio.play(shopBackgroundMusic, {channel = 1, loops = -1})
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    audio.stop()
  elseif (phase == "did") then
    -- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene("shop")
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
  audio.dispose(shopBackgroundMusic)
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
