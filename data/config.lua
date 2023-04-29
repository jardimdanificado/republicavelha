local o = {}
--mapgen
o.mapsize = 2
o.mapquality = 16
--video
o.screen = 
{
    x = 800,
    y = 450
}
o.framerate = 0
o.fpscounter = true
o.fullscreen = false
o.vsync = false
o.runonbackground = true
o.msaa = false
o.interlace = false
o.highdpi = false
o.simple = true--this simplify the blocks to reduce resources usage
o.dynadraw = false
o.rendergrass = true
o.renderterrain = true
o.renderwater = true
o.renderwires = true
o.prettygrass = true
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
