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
      name = "Terrain",
      firstgid = 1,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../../ffmGameJam2/Unity/Assets/Resources/Tiles.png",
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
    },
    {
      name = "Objects",
      firstgid = 81,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../../ffmGameJam2/Unity/Assets/Resources/Objects.png",
      imagewidth = 224,
      imageheight = 96,
      properties = {},
      tiles = {
        {
          id = 3,
          properties = {
            ["objectType"] = "smallTree"
          }
        },
        {
          id = 8,
          properties = {
            ["objectType"] = "bigTree"
          }
        },
        {
          id = 16,
          properties = {
            ["0-prefab"] = "Item",
            ["0-prefab add collider"] = "false",
            ["0-prefab equals position collider"] = "true",
            ["0-prefab path"] = "Prefabs/",
            ["objectType"] = "redGem"
          }
        }
      }
    },
    {
      name = "TerrainOffset",
      firstgid = 102,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "../../ffmGameJam2/Unity/Assets/Resources/Tiles.png",
      imagewidth = 256,
      imageheight = 320,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "ground",
      x = 0,
      y = 0,
      width = 16,
      height = 11,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        10, 10, 10, 10, 10, 10, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58,
        10, 49, 50, 50, 50, 50, 69, 58, 58, 58, 58, 58, 58, 58, 58, 58,
        10, 57, 58, 58, 58, 15, 4, 7, 58, 58, 76, 66, 77, 58, 58, 58,
        10, 57, 15, 4, 4, 14, 73, 23, 58, 58, 59, 10, 57, 58, 58, 58,
        10, 57, 31, 73, 73, 5, 30, 20, 58, 58, 68, 50, 69, 58, 58, 58,
        10, 57, 31, 73, 5, 20, 76, 66, 77, 58, 58, 58, 58, 58, 80, 62,
        10, 57, 31, 73, 23, 58, 59, 10, 57, 58, 58, 58, 58, 80, 47, 38,
        50, 69, 31, 73, 23, 58, 68, 50, 69, 58, 58, 58, 58, 70, 38, 38,
        58, 58, 31, 73, 13, 7, 58, 58, 58, 58, 58, 80, 62, 47, 38, 38,
        58, 15, 14, 73, 73, 13, 7, 58, 80, 62, 62, 47, 38, 38, 38, 38,
        0, 31, 73, 73, 73, 73, 23, 58, 70, 38, 38, 38, 38, 38, 38, 38
      }
    },
    {
      type = "tilelayer",
      name = "decoGround",
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
        0, 0, 0, 0, 0, 0, 0, 92, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 84, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 84, 0, 0, 0, 0, 0, 84, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 92, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
