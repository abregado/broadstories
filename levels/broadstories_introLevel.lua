return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 14,
  height = 8,
  tilewidth = 32,
  tileheight = 32,
  properties = {},
  tilesets = {
    {
      name = "Terrain",
      firstgid = 1,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../assets/Tiles.png",
      imagewidth = 256,
      imageheight = 320,
      properties = {},
      tiles = {
        {
          id = 9,
          properties = {
            ["walkable"] = "false"
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "ground",
      x = 0,
      y = 0,
      width = 14,
      height = 8,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 58, 58, 58, 31, 23, 59, 10, 10, 10, 57, 0, 0,
        0, 0, 58, 15, 4, 14, 23, 68, 50, 50, 50, 69, 0, 0,
        0, 0, 58, 31, 14, 30, 20, 58, 58, 58, 58, 58, 0, 0,
        0, 0, 4, 14, 23, 76, 66, 77, 58, 58, 58, 58, 0, 0,
        0, 0, 73, 5, 20, 59, 10, 57, 58, 58, 58, 58, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      }
    },
    {
      type = "tilelayer",
      name = "ents",
      x = 0,
      y = 0,
      width = 14,
      height = 8,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0, 0, 10, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      }
    }
  }
}
