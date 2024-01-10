local o = {}
--mapgen
o.mapsize = 2
o.mapquality = 16
o.mappolish = 0 -- 0-2 higher values will need more resouces rendering

--general
o.framerate = 0
o.slowrender = 1 --minimum is 1, 0 will freeze the game
o.fullscreen = false
o.vsync = false
o.runonbackground = true
o.multithread = true
--graphics
o.screen = 
{
    x = 800,
    y = 450
}
o.msaa = false
o.interlace = false
o.highdpi = false
o.simple = true--this simplify the blocks to reduce resources usage
o.freeze = false
o.rendergrass = true
o.renderterrain = true
o.renderwater = true
o.renderwires = true
o.prettygrass = false
--camera
o.cameraposition = {x=-20,y=100,z=-20}
o.fov = 65
--other(mostly for internal use dont touch)
o.title = "republica nova"
o.rendertexture = nil
o.paused = true
o.redraw = true
o.world = nil
o.camera = nil
return o
