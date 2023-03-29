local republica = require("src.republicanova")
local terrain = republica.terrain({w=64,h=64},5,4,1)
os.remove("./heightmap.txt")
republica.util.file.save.heightmap(terrain[2],"./heightmap.txt")
