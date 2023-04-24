--
local republica = require("src.republicanova")
--size up to 6 is safe, above 6 you can get buggy maps, default is 2
--layers up to 16 are safe, default is 8
local world = republica.world(2,16)

os.remove("./data/heightmap.txt")
republica.util.file.save.heightmap(world.map.height,"./data/heightmap.txt")
--]]