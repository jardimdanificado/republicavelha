return function (world,republica,options)
    local wheel = rl.GetMouseWheelMove()
    if wheel ~= 0 then
        world.redraw = true
        options.camera.fovy = options.camera.fovy - (wheel*5)
        rl.UpdateCamera(options.camera,0)
    end
    if(rl.IsKeyPressed(rl.KEY_C)) then
        world.redraw = true
        options.freeze = (options.freeze == false) and true or false
        print (options.freeze)
    elseif(rl.IsKeyPressed(rl.KEY_P)) then
        world.redraw = true
        options.prettygrass = (options.prettygrass == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_K)) then
        options._debugger(world,{x=rl.GetMouseX(),y=rl.GetMouseY()})
    elseif(rl.IsKeyPressed(rl.KEY_W)) then
        world.redraw = true
        options.renderwater = (options.renderwater == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_F)) then
        world.redraw = true
        print(world.time)
    elseif(rl.IsKeyPressed(rl.KEY_R)) then
        world.redraw = true
        options.renderwires = (options.renderwires == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_G)) then
        world.redraw = true
        options.rendergrass = (options.rendergrass == false) and true or false
    elseif(rl.IsKeyPressed(rl.KEY_T)) then
        world.redraw = true
        options.renderterrain = (options.renderterrain == false) and true or false
    elseif(rl.IsKeyDown(rl.KEY_PAGE_UP)) then
        world.redraw = true
        options.camera.position.y = options.camera.position.y + 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_PAGE_DOWN)) then
        world.redraw = true
        options.camera.position.y = options.camera.position.y - 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_UP)) then
        world.redraw = true
        options.camera.target.y = options.camera.target.y + 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_DOWN)) then
        world.redraw = true
        options.camera.target.y = options.camera.target.y - 2
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_RIGHT)) then
        world.redraw = true
        options.camera.position = republica.util.math.rotate(options.camera.position,options.camera.target,-3)
        rl.UpdateCamera(options.camera,0)
        if(not rl.IsKeyDown(rl.KEY_LEFT_SHIFT) and not rl.IsKeyDown(rl.KEY_RIGHT_SHIFT)) then
            options.camera.target = {x=#world.map.height/2,y=options.camera.target.y,z=#world.map.height/2}
        end
    elseif(rl.IsKeyDown(rl.KEY_LEFT)) then
        world.redraw = true
        options.camera.position = republica.util.math.rotate(options.camera.position,options.camera.target,3)
        rl.UpdateCamera(options.camera,0)
        if(not rl.IsKeyDown(rl.KEY_LEFT_SHIFT) and not rl.IsKeyDown(rl.KEY_RIGHT_SHIFT)) then
            options.camera.target = {x=#world.map.height/2,y=options.camera.target.y,z=#world.map.height/2}
        end
    elseif(rl.IsKeyDown(rl.KEY_PERIOD)) then
        world.redraw = true
        options.camera.fovy = options.camera.fovy - 1
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyDown(rl.KEY_COMMA)) then
        world.redraw = true
        options.camera.fovy = options.camera.fovy + 1
        rl.UpdateCamera(options.camera,0)
    elseif(rl.IsKeyPressed(rl.KEY_SPACE)) then
        world.redraw = true
        options.paused = (options.paused == false) and true or false
        print("paused = " .. (options.paused and 'true' or 'false'))
    end
end