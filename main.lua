local composer = require( "composer" )

math.randomseed(os.time())

composer.gotoScene( "menu" )
  display.setDefault( "background", 0,0,0 )
