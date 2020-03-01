local composer = require("composer")
local saving = require("saving")

local scene = composer.newScene()

audio.reserveChannels(1)
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables

local shopBackgroundMusic
local uiGroup = display.newGroup()

local json = require("json")

local scoresTable = {}

local filePath = system.pathForFile("savedata.json", system.DocumentsDirectory)

local function loadScores()
  local file = io.open(filePath, "r")

  if file then
    local contents = file:read("*a")
    scoresTable = json.decode(contents)
    io.close(file)
  end

  if (scoresTable == nil or #scoresTable == 0) then
    scoresTable = {0}
  end
end

local function saveScores()
  for i = #scoresTable, 2, -1 do
    table.remove(scoresTable, i)
  end

  local file = io.open(filePath, "w")

  if file then
    file:write(json.encode(scoresTable))
    io.close(file)
  end
end

local function gotoMenu()
  composer.gotoScene("menu", {time = 800, effect = "crossFade"})
end
local function gotoLS()
  composer.gotoScene("game")
  local backgroundMusic = audio.loadStream("sound/bgm1.mp3")

  local backgroundMusicChannel = audio.play(backgroundMusic, {channel = 1, loops = -1, fadein = 10000})
end

local function addUpgrade1()
  if scoresTable[1] >= 1000 then
    scoresTable[1] = scoresTable[1] - 1000
    upgrade1 = true
    upgradeBtn1.alpha = 0.5
    upgradeBtn1:removeEventListener("tap", addUpgrade1)
    -- Save the scores
    saveScores()
  else
    display.newText(
      uiGroup,
      "You don't have enough!",
      display.contentCenterX,
      display.contentCenterX,
      native.systemfont,
      70
    )
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen

  local loadedUpgrades = saving.loadTable("upgrades.json")
  if (upgrade1 == true) then
    local upgradesActive = {
      upgrade1 = true
    }
    saving.saveTable(upgradesActive, "upgrades.json")
  else
    local upgradesActive = {
      upgrade1 = false
    }
    saving.saveTable(upgradesActive, "upgrades.json")
  end

  shopBG = display.newImageRect(uiGroup, "images/red_button_dark.png", 1200, 600)
  shopBG.x = display.contentCenterX
  shopBG.y = display.contentCenterY - 100
  shopBG.alpha = 0.5

  upgradeBtn1 = display.newImageRect(uiGroup, "images/red_button.png", 100, 100)
  upgradeBtn1.x = display.contentCenterX - 500
  upgradeBtn1.y = display.contentCenterY - 300

  if (upgrade1 == true) then
    upgradeBtn1.alpha = 0.5
    upgradeBtn1:removeEventListener("tap", addUpgrade1)
  else
    upgradeBtn1:addEventListener("tap", addUpgrade1)
  end
  -- Load the previous scores
  loadScores()

  -- Insert the saved score from the last game into the table, then reset it
  table.insert(scoresTable, composer.getVariable("finalScore"))
  composer.setVariable("finalScore", 0)

  -- Sort the table entries from highest to lowest
  local function compare(a, b)
    return a > b
  end
  table.sort(scoresTable, compare)

  -- Save the scores
  saveScores()

  local background = display.newImageRect(sceneGroup, "images/shopBG.png", 1920, 1080)
  background.x = display.contentCenterX
  background.y = display.contentCenterY

  local highScoresHeader =
    display.newText(sceneGroup, "Cosmic Ascensions", display.contentCenterX, 100, native.systemFont, 44)

  for i = 1, 10 do
    if (scoresTable[i]) then
      local yPos = 150 + (i * 56)

      local rankNum = display.newText(sceneGroup, i .. ")", display.contentCenterX - 50, yPos, native.systemFont, 36)
      rankNum:setFillColor(1)
      rankNum.anchorX = 1

      local thisScore =
        display.newText(sceneGroup, scoresTable[i], display.contentCenterX - 30, yPos, native.systemFont, 36)
      thisScore.anchorX = 0
    end
  end

  local lsButton = display.newText(sceneGroup, "Start the Game", display.contentCenterX, 800, native.systemFont, 44)
  lsButton:setFillColor(1, 1, 1)

  local shopButton = display.newText(sceneGroup, "Main Menu", display.contentCenterX, 910, native.systemFont, 44)
  shopButton:setFillColor(1, 1, 1)

  lsButton:addEventListener("tap", gotoLS)
  shopButton:addEventListener("tap", gotoMenu)

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
