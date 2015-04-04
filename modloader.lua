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
    print("loading mods")
    local files = fs.getDirectoryItems('modunits')
    for i,v in ipairs(files) do
        print(v)
        local units = require('/modunits/'..ml.getBasename(v))
        if #units>0 then
            print("loaded list contains more than one entry")
            for i,unit in pairs(units) do
                if ml.checkUnitStructure(unit,unitTypes[1]) then
                    local exists = ml.checkUnitTypeExists(unit,unitTypes)
                    if exists then 
                        unitTypes[exists] = unit
                        print(unit.class.." already exists, updating source copy") 
                    else
                        ml.addUnitType(unit,unitTypes)
                        print(unit.class.." does not exist and is valid. Adding to unit types")
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

function ml.getBasename(filename)
  return filename:match("^([^%.]*)%.?") -- "myfile.lua" -> "myfile"
end

return ml
