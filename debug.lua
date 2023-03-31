local republica = require("src.republicanova")
--size up to 6 is safe, above 6 you can get buggy maps, default is 2
--layers up to 16 are safe, default is 8
local terrain = republica.util.func.time({republica.terrain,"full map generated in"},2,16)
os.remove("./heightmap.txt")
republica.util.file.save.heightmap(terrain[2],"./heightmap.txt")
