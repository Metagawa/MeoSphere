local composer = require("composer")

math.randomseed(os.time())
physics.setDrawMode("hybrid")
composer.gotoScene("menu")
display.setDefault("background", 0, 0, 0)
_G.totalScore = 0
_G.carriedScore = 0
