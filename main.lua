
local republica = require("src.republicanova")
local terrain = republica.terrain()
print("")

republica.util.file.save.heightmap(terrain[2],"./heightmap.txt")