return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 16,
  height = 11,
  tilewidth = 32,
  tileheight = 32,
  properties = {},
  tilesets = {
    {
      name = "fantasy-tileset",
      firstgid = 1,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../assets/fantasy-tileset.png",
      imagewidth = 256,
      imageheight = 832,
      properties = {},
      tiles = {
        {
          id = 7,
          properties = {
            ["walkable"] = "0"
          }
        },
        {
          id = 13,
          properties = {
            ["walkable"] = "0"
          }
        },
        {
          id = 24,
          properties = {
            ["walkable"] = "0"
          }
        },
        {
          id = 30,
          properties = {
            ["walkable"] = "0"
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "level",
      x = 0,
      y = 0,
      width = 16,
      height = 11,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
        8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 8, 8,
        8, 9, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 9, 8, 8,
        8, 9, 29, 29, 29, 29, 29, 29, 29, 9, 9, 9, 29, 9, 8, 8,
        8, 9, 29, 14, 29, 29, 29, 29, 29, 9, 31, 9, 29, 9, 8, 8,
        8, 9, 29, 29, 29, 29, 29, 29, 29, 9, 31, 9, 29, 9, 8, 8,
        8, 9, 9, 9, 9, 9, 9, 29, 29, 9, 9, 9, 29, 9, 8, 8,
        8, 25, 25, 25, 25, 25, 9, 29, 29, 29, 29, 29, 29, 9, 8, 8,
        8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 8, 8,
        8, 8, 8, 8, 8, 8, 25, 25, 25, 25, 25, 25, 25, 25, 8, 8,
        8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
      }
    },
    {
      type = "tilelayer",
      name = "ents",
      x = 0,
      y = 0,
      width = 16,
      height = 11,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 3, 4, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 6, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
