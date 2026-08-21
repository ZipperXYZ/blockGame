function SaveGame(savename)
    local data = {}

    data.world = SaveSystem.deconstruct(world)
    data.entities = SaveSystem.deconstruct(entities)


    local serialized = lume.serialize(data)
    love.filesystem.write(""..savename .. ".txt", serialized)
    print("Game saved as: "..savename)
end

function LoadGame(savename)
    if love.filesystem.getInfo(""..savename .. ".txt") then
        print("Loading save: "..savename)

        local data = love.filesystem.read(""..savename .. ".txt")
        data = lume.deserialize(data)

        world = SaveSystem.construct(data.world)
        entities = SaveSystem.construct(data.entities)

        SaveName = savename
        return true
    end
    print("Save file not found: "..savename)
    return false
end

SaveSystem = {}

-- ============================================================
-- CONSTRUCTORS
-- ============================================================

SaveSystem.constructors = {}

function SaveSystem.registerType(typeName, constructor)
    SaveSystem.constructors[typeName] = constructor
end


-- ============================================================
-- DECONSTRUCTOR
-- ============================================================

function SaveSystem.deconstruct(value, seen)
    seen = seen or {}

    local valueType = type(value)

    -- Basic Lua values
    if valueType ~= "table" then
        if valueType == "function"
        or valueType == "userdata"
        or valueType == "thread"
        or valueType == "lightuserdata" then
            return nil
        end

        return value
    end

    -- Prevent infinite recursion from circular references
    if seen[value] then
        return {
            __reference = seen[value]
        }
    end

    local result = {}

    -- Give this table an ID in case something references it later
    local id = tostring(#seen + 1)
    seen[value] = id

    -- Object type
    if value.__type then
        result.__type = value.__type
    end

    -- Serialize all variables
    for key, child in pairs(value) do
        if key ~= "__type" then
            local childValue = SaveSystem.deconstruct(child, seen)

            if childValue ~= nil then
                result[key] = childValue
            end
        end
    end

    return result
end


-- ============================================================
-- CONSTRUCTOR
-- ============================================================

function SaveSystem.construct(value)
    if type(value) ~= "table" then
        return value
    end

    -- References are handled separately
    if value.__reference then
        error("References require a shared-object reconstruction pass")
    end

    local object

    -- This is an object with a registered constructor
    if value.__type then
        local constructor = SaveSystem.constructors[value.__type]

        if not constructor then
            error(
                "No constructor registered for type: "
                .. tostring(value.__type)
            )
        end

        object = constructor()
    else
        -- Normal Lua table
        object = {}
    end

    -- Restore every variable
    for key, child in pairs(value) do
        if key ~= "__type" then
            object[key] = SaveSystem.construct(child)
        end
    end

    return object
end


return SaveSystem