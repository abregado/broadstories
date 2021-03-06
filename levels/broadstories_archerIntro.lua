return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 16,
  height = 9,
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
      width = 16,
      height = 9,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 58, 58, 58, 58, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 58, 58, 58, 58, 58, 76, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 58, 58, 58, 58, 59, 10, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 58, 76, 66, 10, 10, 10, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 10, 10, 10, 49, 69, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 10, 49, 69, 58, 58, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 69, 58, 58, 58, 58, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 58, 58, 58, 58, 58, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 58, 58, 58, 58, 0, 0
      }
    },
    {
      type = "tilelayer",
      name = "ents",
      x = 0,
      y = 0,
      width = 16,
      height = 9,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
