import fs from 'fs';
import {PipeSession} from 'potpiper';

const lua_repl = `
util = require("logic.luatils.init")
function executeLuaCode(code)
    local chunk, err = load(code)
    if chunk then
        local success, result = pcall(chunk)
        if success then
            return result
        else
            return "Error: " .. result
        end
    else
        return "Error: " .. err
    end
end

while true do
    io.flush()
    local command = io.read()
    local result = executeLuaCode(command or 'os.exit()')
    
end

`
if (fs.existsSync('lua_repl.lua')) 
{    
    fs.unlinkSync('lua_repl.lua');
}
fs.writeFileSync('lua_repl.lua', lua_repl);

let lua0 = new PipeSession('luajit',['main.lua']);
let lua1 = new PipeSession('luajit',['lua_repl.lua']);

let id = await lua1.send('print(util.id({"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"}))');

if (fs.existsSync('data/save/temp')) 
{    
    fs.rmSync('data/save/temp',{ recursive: true, force: true });
}
fs.mkdirSync('data/save/temp');
fs.mkdirSync('data/save/temp/map');
await lua0.send(id)
fs.renameSync('data/save/temp', 'data/save/' + id);

lua0.close();
lua1.close();
fs.unlinkSync('lua_repl.lua');