function drawStructureMakerOutline()
    love.graphics.setLineWidth(3)
    love.graphics.setColor(1,1,1,1)

    local x1 = StructureMaker[1].x
    local y1 = StructureMaker[1].y
    local x2 = StructureMaker[2].x
    local y2 = StructureMaker[2].y

    if x1 < x2 then x1 = x1 - 0.5 x2 = x2 + 0.5 else x1 = x1 + 0.5 x2 = x2 - 0.5 end
    if y1 < y2 then y1 = y1 - 0.5 y2 = y2 + 0.5 else y1 = y1 + 0.5 y2 = y2 - 0.5 end

    local x1, y1, size = world:getTileScreenPosition(x1, y1)
    local x2, y2, size = world:getTileScreenPosition(x2, y2)


    love.graphics.line(x1,y1,x1,y2)
    love.graphics.line(x1,y2,x2,y2)
    love.graphics.line(x2,y2,x2,y1)
    love.graphics.line(x2,y1,x1,y1)
    
end
function saveStructureMaker()
    local x1 = StructureMaker[1].x
    local y1 = StructureMaker[1].y
    local x2 = StructureMaker[2].x
    local y2 = StructureMaker[2].y

    local clipboard = ""

    if x1 > x2 then local xo = x2 x2 = x1 x1 = xo end
    if y1 > y2 then local yo = y2 y2 = y1 y1 = yo end

    clipboard = clipboard.."[\"structure\"] = "
    clipboard = clipboard.."\n\t\t{"

    local tileTable = {}

    local layers = {"tiles","topTiles","backTiles"}

    for i=1, #layers do

        local layer = layers[i]

        clipboard = clipboard.."\n\t\t\t[\""..layer.."\"] = "
        clipboard = clipboard.."\n\t\t\t{"

        for y = y2, y1, -1  do

            clipboard = clipboard.."\n\t\t\t\t{ "

            for x = x1, x2  do

                local tile = world:getRawTile(x, y, layer)
                if not checkifinlist(tile,tileTable) then
                    table.insert(tileTable,tile)
                end
                clipboard = clipboard..(getListIndex(tileTable, tile)-1)
                clipboard = clipboard..", "

            end

            clipboard = clipboard.."},"

        end

        clipboard = clipboard.."\n\t\t\t},"
    end
    clipboard = clipboard.."\n\t\t},"



    clipboard = clipboard.."\n\t\t[\"tileTable\"] = "
    clipboard = clipboard.."\n\t\t{"
    clipboard = clipboard.."\n\t\t\t--[0] = nil, -- doesn't place anything"
    clipboard = clipboard.."\n\t\t\t--[0] = { [\"bloc\"] = \"none\", [\"replace\"] = \"all\" ]}, -- places air"
    clipboard = clipboard.."\n\t\t\t--[0] = { [\"bloc\"] = \"dirt\", [\"replace\"] = \"air\" | \"solid\" | \"stone\" | \"all\" ]},"
    clipboard = clipboard.."\n\t\t\t--[0] = { [\"blocs\"] = { { [\"bloc\"] = \"dirt\", [\"weight\"] = 2 }, { [\"bloc\"] = \"stone\", [\"weight\"] = 1 }}, [\"replace\"] = \"air\"},"
    for i = 1, #tileTable do
        clipboard = clipboard.. "\n\t\t\t["..(i-1).."] = { [\"bloc\"] = \""..tileTable[i].."\", [\"replace\"] = \"air\"},"
    end

    clipboard = clipboard.."\n\t\t},"

    clipboard = clipboard.."\n\t\t[\"center\"] = {[\"x\"] = "..math.ceil((x2-x1)/2)..", [\"y\"] = "..math.ceil((y2-y1)/2).."},"
    clipboard = clipboard.."\n\t\t--[\"chests\"] = {  },"

    love.system.setClipboardText(clipboard)

--["center"] = "bottom",
--["chests"] = "{  }",

end

function LoadStructureList()
    MainStructureList = {}
    table.insert(MainStructureList, 
        Structure("essenceTree","unique",1,"trees",6,0.15,100,
        {
            ["minY"] = 0,
            ["maxY"] = 1,
            ["biomes"] = {"essenceLand"},
            ["needsGround"] = true,
            ["checkAir"] = "above",
            ["airNeededX"] = 5,
            ["airNeededY"] = 10,
        }
        ,
        {
            ["structure"] = 
            {
                ["tiles"] = 
                {
                    { 0, 0, 1, 1, 1, 1, 1, 0, 0, },
                    { 0, 1, 1, 1, 1, 1, 1, 1, 0, },
                    { 1, 1, 1, 1, 1, 1, 1, 1, 1, },
                    { 1, 1, 1, 1, 2, 1, 1, 1, 1, },
                    { 1, 1, 1, 1, 2, 1, 1, 1, 1, },
                    { 0, 1, 1, 1, 2, 1, 1, 1, 0, },
                    { 0, 0, 1, 1, 2, 1, 1, 0, 0, },
                    { 0, 0, 0, 0, 2, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 2, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 2, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 2, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 2, 0, 0, 0, 0, },
                    { 0, 0, 0, 2, 2, 2, 0, 0, 0, },
                    { 0, 0, 0, 2, 0, 2, 0, 0, 0, },
                    { 0, 0, 0, 2, 0, 2, 0, 0, 0, },
                },
                ["backTiles"] = 
                {
                    { 0, 1, 1, 1, 1, 1, 1, 1, 0, },
                    { 1, 1, 1, 1, 1, 1, 1, 1, 1, },
                    { 1, 1, 1, 1, 1, 1, 1, 1, 1, },
                    { 1, 1, 1, 1, 1, 1, 1, 1, 1, },
                    { 1, 1, 1, 1, 1, 1, 1, 1, 1, },
                    { 1, 1, 1, 1, 1, 1, 1, 1, 1, },
                    { 0, 1, 1, 1, 1, 1, 1, 1, 0, },
                    { 0, 1, 1, 1, 0, 1, 1, 1, 0, },
                    { 0, 0, 1, 0, 0, 0, 1, 0, 0, },
                    { 0, 0, 0, 0, 0, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 0, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 0, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 0, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 0, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 0, 0, 0, 0, 0, },
                },
            },
            ["tileTable"] = 
            {
                [0] = nil,
                [1] = {["bloc"] = "essenceLeaves", ["replace"] = "air" } ,
                [2] = {["bloc"] = "essenceWood", ["replace"] = "all" } ,
            },
            ["center"] = {["x"] = 5, ["y"] = 13},
            --["chests"] = "{  }",
        }
        ,{})
    )
    
    table.insert(MainStructureList, 
        Structure("essenceTree2","unique",2,"trees",6,0.15,100,
        {
            ["minY"] = 0,
            ["maxY"] = 1,
            ["biomes"] = {"essenceLand"},
            ["needsGround"] = true,
            ["checkAir"] = "above",
            ["airNeededX"] = 2,
            ["airNeededY"] = 7,
        }
        ,
        {
            ["structure"] = 
            {
                ["tiles"] = 
                {
                    { 0, 1, 1, 1, 0, },
                    { 1, 1, 1, 1, 1, },
                    { 1, 1, 1, 1, 1, },
                    { 0, 1, 2, 1, 0, },
                    { 0, 0, 2, 0, 0, },
                    { 0, 0, 2, 0, 0, },
                    { 0, 0, 2, 0, 0, },
                    { 0, 0, 2, 0, 0, },
                    { 0, 0, 2, 0, 0, },
                },
                ["backTiles"] = 
                {
                    { 0, 1, 1, 1, 0, },
                    { 1, 1, 1, 1, 1, },
                    { 1, 1, 1, 1, 1, },
                    { 1, 1, 1, 1, 1, },
                    { 0, 1, 0, 1, 0, },
                    { 0, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 0, },
                    { 0, 0, 0, 0, 0, },
                },
            },
            ["tileTable"] = 
            {
                --[0] = nil, -- doesn't place anything
                --[0] = { ["bloc"] = "none", ["replace"] = "all" ]}, -- places air
                --[0] = { ["bloc"] = "dirt", ["replace"] = "air" | "solid" | "stone" | "all" ]},
                --[0] = { ["blocs"] = { { ["bloc"] = "dirt", ["weight"] = 2 }, { ["bloc"] = "stone", ["weight"] = 1 }}, ["replace"] = "air"},
                [0] = nil,
                [1] = { ["bloc"] = "essenceLeaves", ["replace"] = "air"},
                [2] = { ["bloc"] = "essenceWood", ["replace"] = "all"},
            },
            ["center"] = {["x"] = 3, ["y"] = 8},
            --["chests"] = {  },
                --["chests"] = "{  }",
        }
        ,{})
    )

    table.insert(MainStructureList, 
        Structure("cactus1","unique",3,"trees",1,0.15,100,
        {
            ["minY"] = 0,
            ["maxY"] = 1,
            ["biomes"] = {"duneland"},
            ["needsGround"] = true,
            ["checkAir"] = "above",
            ["airNeededX"] = 1,
            ["airNeededY"] = 4,
        }
        ,
        {
            ["structure"] = 
		{
			["tiles"] = 
			{
				{ 0, },
				{ 0, },
				{ 0, },
				{ 0, },
			},
		},
		["tileTable"] = 
		{
			--[0] = nil, -- doesn't place anything
			--[0] = { ["bloc"] = "none", ["replace"] = "all" ]}, -- places air
			--[0] = { ["bloc"] = "dirt", ["replace"] = "air" | "solid" | "stone" | "all" ]},
			--[0] = { ["blocs"] = { { ["bloc"] = "dirt", ["weight"] = 2 }, { ["bloc"] = "stone", ["weight"] = 1 }}, ["replace"] = "air"},
			[0] = { ["bloc"] = "cactus", ["replace"] = "air"},
			[1] = { ["bloc"] = "none", ["replace"] = "-"},
		},
		["center"] = {["x"] = 2, ["y"] = 4},
		--["chests"] = {  },
        }
        ,{})
    )
    table.insert(MainStructureList, 
        Structure("cactus2","unique",4,"trees",1,0.15,100,
        {
            ["minY"] = 0,
            ["maxY"] = 1,
            ["biomes"] = {"duneland"},
            ["needsGround"] = true,
            ["checkAir"] = "above",
            ["airNeededX"] = 1,
            ["airNeededY"] = 4,
        }
        ,
        {
            ["structure"] = 
		{
			["tiles"] = 
			{
				{ 0, 1, 0, },
				{ 1, 1, 1, },
				{ 0, 1, 0, },
			},
		},
		["tileTable"] = 
		{
			--[0] = nil, -- doesn't place anything
			--[0] = { ["bloc"] = "none", ["replace"] = "all" ]}, -- places air
			--[0] = { ["bloc"] = "dirt", ["replace"] = "air" | "solid" | "stone" | "all" ]},
			--[0] = { ["blocs"] = { { ["bloc"] = "dirt", ["weight"] = 2 }, { ["bloc"] = "stone", ["weight"] = 1 }}, ["replace"] = "air"},
			[0] = { ["bloc"] = "none", ["replace"] = "-"},
			[1] = { ["bloc"] = "cactus", ["replace"] = "air"},
		},
		["center"] = {["x"] = 2, ["y"] = 3},
		--["chests"] = {  },
        }
        ,{})
    )
    table.insert(MainStructureList, 
        Structure("cactus3","unique",5,"trees",1,0.15,100,
        {
            ["minY"] = 0,
            ["maxY"] = 1,
            ["biomes"] = {"duneland"},
            ["needsGround"] = true,
            ["checkAir"] = "above",
            ["airNeededX"] = 1,
            ["airNeededY"] = 4,
        }
        ,
        {
            ["structure"] = 
		{
			["tiles"] = 
			{
				{ 0, 1, 0, },
				{ 0, 0, 0, },
				{ 1, 0, 1, },
				{ 1, 0, 1, },
			},
		},
		["tileTable"] = 
		{
			--[0] = nil, -- doesn't place anything
			--[0] = { ["bloc"] = "none", ["replace"] = "all" ]}, -- places air
			--[0] = { ["bloc"] = "dirt", ["replace"] = "air" | "solid" | "stone" | "all" ]},
			--[0] = { ["blocs"] = { { ["bloc"] = "dirt", ["weight"] = 2 }, { ["bloc"] = "stone", ["weight"] = 1 }}, ["replace"] = "air"},
			[0] = { ["bloc"] = "cactus", ["replace"] = "air"},
			[1] = { ["bloc"] = "none", ["replace"] = "-"},
		},
		["center"] = {["x"] = 2, ["y"] = 4},
		--["chests"] = {  },
        }
        ,{})
    )
    table.insert(MainStructureList, 
        Structure("cactus4","unique",6,"trees",1,0.15,100,
        {
            ["minY"] = 0,
            ["maxY"] = 1,
            ["biomes"] = {"duneland"},
            ["needsGround"] = true,
            ["checkAir"] = "above",
            ["airNeededX"] = 1,
            ["airNeededY"] = 4,
        }
        ,
        {
            ["structure"] = 
		{
			["tiles"] = 
			{
				{ 0, 1, 0, },
				{ 1, 1, 1, },
				{ 1, 0, 1, },
				{ 1, 1, 1, },
				{ 0, 1, 0, },
			},
		},
		["tileTable"] = 
		{
			--[0] = nil, -- doesn't place anything
			--[0] = { ["bloc"] = "none", ["replace"] = "all" ]}, -- places air
			--[0] = { ["bloc"] = "dirt", ["replace"] = "air" | "solid" | "stone" | "all" ]},
			--[0] = { ["blocs"] = { { ["bloc"] = "dirt", ["weight"] = 2 }, { ["bloc"] = "stone", ["weight"] = 1 }}, ["replace"] = "air"},
			[0] = { ["bloc"] = "none", ["replace"] = "-"},
			[1] = { ["bloc"] = "cactus", ["replace"] = "air"},
		},
		["center"] = {["x"] = 2, ["y"] = 5},
		--["chests"] = {  },
        }
        ,{})
    )

    table.insert(MainStructureList, 
        Structure("tree","unique",7,"trees",2,0.15,100,
        {
            ["minY"] = 0,
            ["maxY"] = 1,
            ["biomes"] = {"none"},
            ["needsGround"] = true,
            ["checkAir"] = "above",
            ["airNeededX"] = 2,
            ["airNeededY"] = 10,
        }
        ,
        {
            ["structure"] = 
		{
			["tiles"] = 
			{
				{ 0, 0, 0, 1, 0, 0, 0, },
				{ 0, 0, 1, 1, 1, 0, 0, },
				{ 0, 1, 1, 1, 1, 1, 0, },
				{ 0, 1, 1, 1, 1, 1, 0, },
				{ 0, 1, 1, 1, 1, 1, 0, },
				{ 1, 1, 1, 2, 1, 1, 1, },
				{ 1, 1, 1, 2, 1, 1, 1, },
				{ 1, 1, 1, 2, 1, 1, 1, },
				{ 0, 1, 1, 2, 1, 1, 0, },
				{ 0, 0, 0, 2, 0, 0, 0, },
				{ 0, 0, 0, 2, 0, 0, 0, },
				{ 0, 0, 0, 2, 0, 0, 0, },
				{ 0, 0, 0, 2, 0, 0, 0, },
				{ 0, 0, 0, 2, 0, 0, 0, },
				{ 0, 0, 0, 2, 0, 0, 0, },
				{ 0, 0, 0, 2, 0, 0, 0, },
				{ 0, 0, 2, 2, 2, 0, 0, },
				{ 0, 0, 2, 0, 2, 0, 0, },
			},
		},
		["tileTable"] = 
		{
			--[0] = nil, -- doesn't place anything
			--[0] = { ["bloc"] = "none", ["replace"] = "all" ]}, -- places air
			--[0] = { ["bloc"] = "dirt", ["replace"] = "air" | "solid" | "stone" | "all" ]},
			--[0] = { ["blocs"] = { { ["bloc"] = "dirt", ["weight"] = 2 }, { ["bloc"] = "stone", ["weight"] = 1 }}, ["replace"] = "air"},
			[0] = { ["bloc"] = "none", ["replace"] = "-"},
			[1] = { ["bloc"] = "leaves", ["replace"] = "air"},
			[2] = { ["bloc"] = "wood", ["replace"] = "all"},
		},
		["center"] = {["x"] = 4, ["y"] = 17},
		--["chests"] = {  },
        }
        ,{})
    )

    --[[table.insert(MainStructureList, 
        Structure("cactus1","unique",2,"trees",6,0.15,100,
        {
            ["minY"] = 0,
            ["maxY"] = 1,
            ["biomes"] = {"essenceLand"},
            ["needsGround"] = true,
            ["checkAir"] = "above",
            ["airNeededX"] = 2,
            ["airNeededY"] = 7,
        }
        ,
        {
            
        }
        ,{})
    )]]
--["center"] = {["x"] = 4, ["y"] = 4},
--["chests"] = {  },
end

function AttemptAllStructureGenerations(chunk, chunkX,chunkY,chunkWidth, generationStep, stepList, worldSeed, depthProgression, biomeSize, biomeList, world)
    --print("helo")
    --print("Attempting structure generation for chunk at "..chunkX..","..chunkY.." at step "..generationStep)
    for i = 1, #MainStructureList do
        if MainStructureList[i].spawnStep == generationStep then
            --print("Attempting to spawn structure "..MainStructureList[i].name.." at chunk "..chunkX..","..chunkY.." at step "..generationStep)
            MainStructureList[i]:attemptSpawn(chunk, chunkX,chunkY,chunkWidth, generationStep, stepList, worldSeed, depthProgression, biomeSize, biomeList, world)
        end
    end
end