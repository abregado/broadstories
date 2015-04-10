local fs = love.filesystem

local ml = {}

function ml.checkStructure()
    local created = fs.isDirectory('/modlevels')
    if not created then
        --new install create all folders
        love.filesystem.createDirectory('modlevels')
        love.filesystem.createDirectory('modassets')
        love.filesystem.createDirectory('modunits')
        print("First Load. Set up save directory structure")
    else
        print("Save directory was already set up")
    end
end

function ml.loadUnits(unitTypes)
    print("loading mods units")
    local files = fs.getDirectoryItems('modunits')
    local newUnits = 0
    local changedUnits = 0
    for i,v in ipairs(files) do
        print(v)
        local filename, ext = ml.getBasenameAndExtension(v)
        if ext == 'lua' then 
            local units = require('/modunits/'..filename)
            if #units>0 then
                print("loaded list contains more than one entry")
                for i,unit in pairs(units) do
                    if ml.checkUnitStructure(unit,unitTypes[1]) then
                        local exists = ml.checkUnitTypeExists(unit,unitTypes)
                        if exists then 
                            unitTypes[exists] = unit
                            print(unit.class.." already exists, updating source copy") 
                            changedUnits = changedUnits +1
                        else
                            ml.addUnitType(unit,unitTypes)
                            print(unit.class.." does not exist and is valid. Adding to unit types")
                            newUnits = newUnits+1
                        end
                    else
                        print("entry was not a valid unit structure")
                    end
                end
            else
                print("loaded list contained no entries")
            end
        end
    end
    return newUnits,changedUnits
end

function ml.addUnitType(unit,unitTypes)
    table.insert(unitTypes,unit)
end

function ml.checkUnitTypeExists(unit,unitTypes)
    for i,v in pairs(unitTypes) do
        if v.class == unit.class then
            return i
        end
    end
    return nil
end

function ml.checkUnitStructure(unit,template)
    local result = true
    for i,v in pairs(template) do
        
        if type(unit[i]) == type(template[i]) then
            --this value is aok
            --print(i,tostring(type(unit[i]) == type(template[i])))
        else
            result = false
            print("--",i,"FAILED -- ")
        end
    end
    return result    
end

function ml.getBasenameAndExtension(filename)
  return filename:match("^([^%.]*)%.?(.*)$") -- "myfile.lua" -> "myfile", "lua"
end

function ml.loadLevels(levelList)
    print("loading mod levels")
    local files = fs.getDirectoryItems('modlevels')
    local newLevels = 0
    for i,v in ipairs(files) do
        print(v)
        local filename, ext = ml.getBasenameAndExtension(v)
        if ext == 'lua' then 
            local level = require('/modlevels/'..filename)
            if level then
                print("loaded level is an array... continuing")
                if ml.checkLevelStructure(level) then
                    ml.addLevel(level,levelList)
                    print(v.." was a valid level and has been added")
                else
                    print("not a valid level")
                end
            else
                print("loaded item was not a level")
            end
        end
    end
    return newLevels
end

function ml.checkLevelStructure(level)
    if not level.width then print("-- FAILED width --") return false end
    if not level.height then print("-- FAILED height --") return false end
    if not level.tilewidth then print("-- FAILED tilewidth --") return false end
    if not level.tileheight then print("-- FAILED tileheight --") return false end
    if not level.tilesets[1] then
        print("-- FAILED no tilesets --") return false
    else
        local tileset = level.tilesets[1].image
        local path = string.sub(tileset,3)
        if not fs.exists(path) then print('cannot find custom tileset') return false end
    end
    if not level.layers[1] then print("-- FAILED layer1 --") return false end
    if not level.layers[2] then print("-- FAILED layer2 --") return false end
    return true
end

function ml.addLevel(level,levelList)
    table.insert(levelList,level)
end

return ml
