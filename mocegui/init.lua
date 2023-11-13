--Mouse Centered Graphical User Interface(MoCeGUI)
local util = require "republicavelha.luatils.init"
if not rl and not love then
    for i, v in ipairs(arg or {}) do
        if util.string.includes(v,'-gl') then
            gl = util.string.replace(v,'-gl','')
            print(gl)
        end
    end
    if not gl then
        gl = '21'
    end
    rl = require('mocegui.lib.raylib')
    gl = nil
end

package.path = 'mocegui/luatils/?.lua' .. ";" .. package.path
local mocegui={version="0.1.95",pending = {},font={size = 12}}
mocegui.util = util
local config = require "mocegui.data.config"
local mouse =
{
	draggin = false
}

mocegui.window = {}

function mocegui.closeWindow()
	mocegui.window[1] = nil
	mocegui.window = util.array.clear(mocegui.window)
end

function mocegui.newText(win,text,size,color,pcolor)
	local newtxt = function (txt)
		return {
			position = {x=4,y=4},
			size = size or mocegui.font.size,
			color = {r=255 or color.r,g=255 or color.g,b=255 or color.b,a=255 or color.a},
			text = (txt .. '') or 'blank'
		}
	end
	local insert = function(win,txt)
		table.insert(win.text,1,newtxt(txt))
		win.text[1].position.y = win.text[1].position.y + (mocegui.font.size*(#win.text+(not win.title and -1 or 0)))
		win.size.y = (mocegui.font.size*(#win.text+(not win.title and 0 or 1))) + 8
		if (((#txt/2.5)*(mocegui.font.size+2))-2) > win.size.x then
			win.size.x = (((#txt/2.5)*(mocegui.font.size+2))-2)
		end
		win.size.y = (mocegui.font.size*(#win.text+(not win.title and 0 or 1))) + 8
		return win.text[1]
	end
	if util.string.includes(text,'\n') then
		local result = {}
		local temp
		for key, value in ipairs(util.string.split(text,'\n')) do
			table.insert(result,1,insert(win,value))
		end
		return result
	else
		return insert(win,text)
	end
end

function mocegui.newFreeButton(win,position,size,func,args,color,pcolor)
	local btn = {
		position = position,
		size = size or {x=mocegui.font.size,y=mocegui.font.size},
		color = color or {r=0,g=127,b=127,a=255},
		pcolor = pcolor or {r=127,g=25,b=26,a=255},
		func = func or mocegui.closeWindow,
		args = args or {}
	}
	btn.position = position or {x=size.x-mocegui.font.size,y=0}
	table.insert(win.button,1,btn)
	return win.button[1]
end

function mocegui.newListButton(win,func,args,text,color,pcolor)
	if text then
		win.text.new(text)
	end
	local btn = {
		position = {x=0,y=0},
		size = {
            x=mocegui.font.size-4,
            y=mocegui.font.size-4
        },
		color = color or {r=0,g=127,b=127,a=255},
		pcolor = pcolor or {r=127,g=25,b=26,a=255},
		func = func or mocegui.closeWindow,
		args = args or {}
	}
	btn.position = {x = win.size.x/2 - btn.size.x/2, y = (mocegui.font.size/3) + (mocegui.font.size*(#win.text+(not win.title and -1 or 0)))}
	if text then
		btn.position.x = win.size.x-mocegui.font.size
	end
	table.insert(win.button,1,btn)
	return win.button[1]
end

function mocegui.newButton(win,func,args,text,color,pcolor)
	if text then
		local txt = win.text.new(text)
		txt.color = pcolor or txt.color
		txt.position.x = (win.size.x/2)-((((#txt.text/2.5)*(mocegui.font.size+2))-2)/2)+2
		txt.position.y = txt.position.y - 1
	end
	local btn = {
		position = {x=0,y=0},
		size = {
            x=mocegui.font.size-4,
            y=mocegui.font.size-4
        },
		color = color or {r=0,g=127,b=127,a=255},
		pcolor = pcolor or {r=127,g=25,b=26,a=255},
		func = func or mocegui.closeWindow,
		args = args or {}
	}
	btn.position = {x = win.size.x/2 - btn.size.x/2, y = (mocegui.font.size/3) + (mocegui.font.size*(#win.text+(not win.title and -1 or 0)))}
	if text then
		btn.size.x = (((#text/2.5)*(mocegui.font.size+2)))
		btn.position.x = btn.position.x - (btn.size.x/2) + 8
	end
	table.insert(win.button,1,btn)
	return win.button[1]
end

function mocegui.newSwitch(win,text,object,name)
    local txt = win.text.new(text)
    local button = mocegui.newFreeButton(win,
        {
            x = win.size.x-mocegui.font.size,
            y = (mocegui.font.size/3) + (mocegui.font.size*(#win.text+(not win.title and -1 or 0)))
        },
		{
            x=mocegui.font.size-4,
            y=mocegui.font.size-4
        }
    )
    button.func = function()
        button.color = (object[name]) and rl.RED or rl.GREEN
        object[name] = (object[name] == false) and true or false
    end
	button.color = (not object[name]) and rl.RED or rl.GREEN
    button.args = {}
	return txt, button
end

function mocegui.newWindow(title,position,size,color)
	local win = 
	{
		func = nil,
		color= color or {76,76,104,255},
		position= position or {x=16,y=16},
		size=size or {x=16,y=16},
		text = {},
		button = not title and 
		{
		} or
		{
			{
				position = {x=(size and size.x or 50)-mocegui.font.size,y=0},
				size = {x=mocegui.font.size,y=mocegui.font.size},
				color = {r=255,g=127,b=127,a=255},
				pcolor = {r=127,g=25,b=25,a=255},
				func = mocegui.closeWindow,
				args = {}
			}
		},
		hide = false,
		title = title
	}
	win.text.new = function(text,size,color,pcolor)
		return mocegui.newText(win,text,size,color,pcolor)
	end
	win.button.new = function(func,args,text,color,pcolor)
		return mocegui.newListButton(win,func,args,text,color,pcolor)
	end
	win.switch = {}
	win.switch.new = function(text,object,name)
		return mocegui.newSwitch(win,text,object,name)
	end
	
	table.insert(mocegui.window,2,win)
	mocegui.window = util.array.clear(mocegui.window)
	return win
end

function mocegui.newTextWindow(title,text,position)
	local win = mocegui.newWindow(title,position)
	local txt = util.string.split(text,'\n')
	local len = #txt[1]
	for key, value in ipairs(txt) do
		if #value > len then
			len = #value
		end
	end
	--win.size.x = (((len/2.5)*(mocegui.font.size+2))-2)
	--win.size.y = ((#txt)*(mocegui.font.size)+4)
	win.text.new(text,mocegui.font.size)
	return win
end

mocegui.timeout = function(win,seconds)
	util.agendar(mocegui.pending, function()
        for i,v in ipairs(mocegui.window) do
            if v == win then
                mocegui.window = util.array.clear(mocegui.window)
                util.table.move(mocegui.window,i,#mocegui.window)
                mocegui.window[#mocegui.window] = nil
                mocegui.window = util.array.clear(mocegui.window)
                break
            end
        end
    end,{0},seconds)
end

local function bRect(px,py,sx,sy,color,bordercolor)
	rl.DrawRectangle(px-1, py-1, sx+2, sy+2, bordercolor or rl.WHITE)
	rl.DrawRectangle(px, py, sx, sy, color or rl.BLUE)
end

function mocegui.spawndebug(customposition)
	local debugwin = mocegui.newWindow('debug window',customposition or {x=1,y=1},{x=(mocegui.font.size+2)*10,y=(mocegui.font.size+2)*4})
	local debugtxt = debugwin.text.new(mocegui.titlecache .. "\nCurrent FPS: " .. tostring(rl.GetFPS()) .. "\nWindow amount:" .. #mocegui.window)
	debugwin.func = function ()
		debugtxt[#debugtxt-1].text = "Window amount:" .. #mocegui.window
		debugtxt[#debugtxt-2].text = "Current FPS: " .. rl.GetFPS()
	end
	return debugwin
end

function mocegui.startup(screen,fontsize)
	local iconImageData = rl.LoadImage("mocegui/png/icon.png")
    rl.SetWindowIcon(iconImageData)
	config.screen = screen or config.screen
	mocegui.font.size = fontsize or mocegui.font.size
	table.insert(mocegui.font,rl.LoadFontEx("mocegui/data/font/Cascadia.ttf", mocegui.font.size, nil, 0))
	mocegui.titlecache = "MoCeGUI-" .. mocegui.version
	config.rendertexture = rl.LoadRenderTexture(config.screen.x, config.screen.y)
end

function mocegui.load()
	if config.fullscreen then
        rl.SetConfigFlags(rl.FLAG_FULLSCREEN_MODE)
    end
    if config.vsync then
        rl.SetConfigFlags(rl.FLAG_VSYNC_HINT)
    end
    if config.runonbackground then
        rl.SetConfigFlags(rl.FLAG_WINDOW_ALWAYS_RUN)
    end
    if config.msaa then
        rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT)
    end
    if config.interlace then
        rl.SetConfigFlags(rl.FLAG_INTERLACED_HINT)
    end 
    if config.highdpi then
        rl.SetConfigFlags(rl.FLAG_WINDOW_HIGHDPI)
    end
	rl.SetConfigFlags(rl.FLAG_WINDOW_RESIZABLE)
    rl.InitWindow(config.screen.x,config.screen.y, "MoCeGUI-" .. mocegui.version)
    rl.SetTargetFPS(0)
	
	mocegui.startup()
	mocegui.spawndebug()
end

function mocegui.keypressed(key)
end

function mocegui.mousereleased()
	local x,y = rl.GetMouseX(),rl.GetMouseY()
	if mocegui.window[1] then
		if rl.IsMouseButtonReleased(0) then
			if mocegui.window[1].title and
			x >= mocegui.window[1].position.x  and
			x <= mocegui.window[1].position.x + mocegui.window[1].size.x  and
			y >= mocegui.window[1].position.y  and
			y <= mocegui.window[1].position.y + mocegui.font.size then
				if mouse.draggin then
					mouse.draggin = false
				end
			end
			mocegui.window[1].button = util.array.clear(mocegui.window[1].button)
			for index, _button in ipairs(mocegui.window[1].button) do
				if _button and _button.position and mocegui.window[1] and mocegui.window[1].position then
					if x >= mocegui.window[1].position.x + _button.position.x  and
					   x <= mocegui.window[1].position.x + _button.position.x + _button.size.x  and
					   y >= mocegui.window[1].position.y + _button.position.y  and
					   y <= mocegui.window[1].position.y + _button.position.y + _button.size.y  then
						_button.func(mocegui.window)
						_button.pressed = false
					end
				end
			end
			if mouse.draggin then
				mouse.draggin = false
			end
		elseif rl.IsMouseButtonReleased(2) then
			if mouse.draggin then
				mouse.draggin = false
			end
		elseif rl.IsMouseButtonReleased(1) then
			if x >= mocegui.window[1].position.x  and
			x <= mocegui.window[1].position.x + mocegui.window[1].size.x  and
			y >= mocegui.window[1].position.y  and
			y <= mocegui.window[1].position.y + mocegui.window[1].size.y  then
				mocegui.closeWindow()
			end
		end
	end
end

function mocegui.mousepressed()
	local x,y = rl.GetMouseX(),rl.GetMouseY()
	if mocegui.window[1] then
		if rl.IsMouseButtonPressed(0) or rl.IsMouseButtonPressed(1) or rl.IsMouseButtonPressed(2) then
			if not (x >= mocegui.window[1].position.x  and
			x <= mocegui.window[1].position.x + mocegui.window[1].size.x  and
			y >= mocegui.window[1].position.y  and
			y <= mocegui.window[1].position.y + mocegui.window[1].size.y ) then
				for index, win in pairs(mocegui.window) do
					if x >= win.position.x  and
					x <= win.position.x + win.size.x  and
					y >= win.position.y  and
					y <= win.position.y + win.size.y  then
						if mouse.draggin then
							mouse.draggin = false
						end
						util.table.move(mocegui.window,index,1)
						break
					end
				end
			end
		end
		if rl.IsMouseButtonPressed(0) then
			if mocegui.window[1].title and
			x >= mocegui.window[1].position.x  and
			x <= mocegui.window[1].position.x + mocegui.window[1].size.x  and
			y >= mocegui.window[1].position.y  and
			y <= mocegui.window[1].position.y + mocegui.font.size then
				mouse.draggin = mocegui.window[1].position
			end
			for index, _button in ipairs(mocegui.window[1].button) do
				if x >= mocegui.window[1].position.x + _button.position.x  and
				x <= mocegui.window[1].position.x + _button.position.x + _button.size.x  and
				y >= mocegui.window[1].position.y + _button.position.y  and
				y <= mocegui.window[1].position.y + _button.position.y + _button.size.y  then
					_button.pressed = true
				end
			end
		elseif rl.IsMouseButtonPressed(2) then
			if x >= mocegui.window[1].position.x  and
			x <= mocegui.window[1].position.x + mocegui.window[1].size.x  and
			y >= mocegui.window[1].position.y  and
			y <= mocegui.window[1].position.y + mocegui.window[1].size.y then
				mouse.draggin = mocegui.window[1].position
			end
		end
	end
end

function mocegui.mousedown()
	if not mocegui.window[1] then
		return
	end
	local x,y = rl.GetMouseX(),rl.GetMouseY()
	local delta = rl.GetMouseDelta()
	if rl.IsMouseButtonDown(2) then
		if mouse.draggin then
			mouse.draggin.x = mouse.draggin.x + delta.x
			mouse.draggin.y = mouse.draggin.y + delta.y
		end
	elseif rl.IsMouseButtonDown(0) then
		if mouse.draggin then
			mouse.draggin.x = mouse.draggin.x + delta.x
			mouse.draggin.y = mouse.draggin.y + delta.y
		end
	end
end

function mocegui.bakeframe()
	util.array.selfclear(mocegui.window)
	rl.BeginTextureMode(config.rendertexture)
	--love.graphics.push()
	rl.ClearBackground({r=0,g=0,b=0,a=0})
	for index = #mocegui.window, 1, -1 do
		local v = mocegui.window[index]
		if v.func then
			v.func(v.args and unpack(v.args) or 0)
		end
		if v.title then
			rl.DrawRectangle(v.position.x-1, v.position.y-1, v.size.x+2, v.size.y+2, rl.WHITE)
			rl.DrawRectangle(v.position.x, v.position.y+(mocegui.font.size+1), v.size.x, v.size.y-(mocegui.font.size+1),v.color)
			if mocegui.font[1] then
				rl.DrawTextEx(mocegui.font[1],v.title, {x=v.position.x,y=v.position.y}, mocegui.font.size, 0, v.color)
			else
				rl.DrawText(v.title, v.position.x,v.position.y, mocegui.font.size, v.color)
			end
		else
			bRect(v.position.x, v.position.y, v.size.x, v.size.y, v.color)
		end
		for key, button in ipairs(v.button) do
			if button.func ~= mocegui.closeWindow then
				bRect(v.position.x+button.position.x, v.position.y+button.position.y, button.size.x, button.size.y,(button.pressed and button.pcolor or button.color))
			else
				local c = button.pressed and button.pcolor or button.color
				rl.DrawRectangle(v.position.x+button.position.x, v.position.y+button.position.y, button.size.x, button.size.y, c)
			end
		end
		for key, text in ipairs(v.text) do
			if mocegui.font[1] then
				rl.DrawTextEx(mocegui.font[1],text.text, {x=v.position.x+text.position.x, y=v.position.y+text.position.y}, mocegui.font.size, 0, text.color)
			else
				rl.DrawText(text.text, v.position.x+text.position.x, v.position.y+text.position.y, mocegui.font.size, text.color)
			end
		end
			--world.redraw = false
			--end
	end
	rl.EndTextureMode();
	return config.rendertexture.texture
end

function mocegui.updateMouse()
	mocegui.mousepressed()
    mocegui.mousereleased()
    mocegui.mousedown()
end

function mocegui.update()
	mocegui.util.repeater(mocegui.pending)
	mocegui.updateMouse()
	if(rl.IsWindowResized()) then
        rl.UnloadRenderTexture(config.rendertexture)
        config.screen.x = rl.GetScreenWidth()
        config.screen.y = rl.GetScreenHeight()
        config.rendertexture = rl.LoadRenderTexture(config.screen.x, config.screen.y)
    end
end

function mocegui.render()
    mocegui.update()
    rl.BeginDrawing()
    --if(world.redraw == true and config.freeze == false) then
	rl.ClearBackground(rl.BLACK)
	--rl.BeginMode3D(config.camera)
	--rl.EndMode3D()
	mocegui.bakeframe()
    rl.DrawTexturePro(
        config.rendertexture.texture,
        {
            x=0,
            y=0,
            width=config.screen.x,
            height=config.screen.y*-1
        },
        {x=0,y=0,width=config.screen.x,height=config.screen.y},
        {x=0,y=0},
        0,
        rl.WHITE
    );
    rl.EndDrawing()
end

mocegui.close = function()
	rl.CloseWindow()
end

mocegui.mouse = mouse

return mocegui