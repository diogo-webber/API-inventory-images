
--  ================================================================== --
-- |      Library Designed by Leonidas IV  - Copyright 2022-2022      |
--  ================================================================== --

local _G = GLOBAL

if _G.rawget(_G, INV_IMAGES_API_LOADED) then return end -- Don't load the file again ;)

_G.INV_IMAGES_API_LOADED = true
_G.INV_IMAGES_API_VERSION = "1.0"

--> Abstractions:

local HAMenabled = _G.IsDLCEnabled(_G.PORKLAND_DLC)

local inventoryItemAtlasses = not HAMenabled and {} or {"images/inventoryimages.xml", "images/inventoryimages_2.xml"}
local inventoryItemAtlasLookup = {}

local io = _G.require("io")

------------------------------------------------------------------------------------

local function ProcessAtlas(atlas, imagename)
    if HAMenabled then
        if _G.TheSim:AtlasContains(atlas, imagename) then
            inventoryItemAtlasLookup[imagename] = atlas
            return atlas
        end
    end

    local success, file = _G.pcall(io.open, atlas)
    assert(success, '[API]: The atlas "'..atlas..'" can not be found.')

    local xml = file:read("*all")
    file:close()

    local images = xml:gmatch('<Element name="(.-)"')

    for tex in images do
        inventoryItemAtlasLookup[tex] = atlas --> Cache the textures.
        if imagename == tex then
            return atlas
        end
    end

end

local function ProcessNewImage(imagename)
    for _, atlas in ipairs(inventoryItemAtlasses) do
        local successed_atlas = ProcessAtlas(atlas, imagename)
        if successed_atlas then
            return successed_atlas
        end
    end

    return "images/inventoryimages.xml"
end

-- A re-implementation of GetInventoryItemAtlas
function _G.GetInventoryItemAtlas(imagename) --> You don't need to call this
    return inventoryItemAtlasLookup[imagename] or ProcessNewImage(imagename)
end

local GetInventoryItemAtlas = _G.GetInventoryItemAtlas

if not HAMenabled then --> Port the GetInventoryItemAtlas uses from HAM.
    local function HookOnDrawnFn(inst)        
        local _OnDrawnFn = inst.components.drawable.ondrawnfn
        inst.components.drawable.ondrawnfn = function(inst, image, src)
            _OnDrawnFn(inst, image, src)
            if image ~= nil then
                local atlas = (src and src.components.inventoryitem and src.components.inventoryitem:GetAtlas()) or GetInventoryItemAtlas(image..".tex") 
                inst.AnimState:OverrideSymbol("SWAP_SIGN", atlas, image..".tex")
            end
        end
    end

    AddPrefabPostInit("minisign", HookOnDrawnFn)
    AddPrefabPostInit("minisign_drawn", HookOnDrawnFn)

    function _G.Ingredient:GetAtlas(imagename)
        self.atlas = self.atlas or GetInventoryItemAtlas(imagename)
        return self.atlas
    end

    function _G.Recipe:GetAtlas()
        self.atlas = self.atlas or GetInventoryItemAtlas(self.image)
        return self.atlas
    end

    AddComponentPostInit("inventoryitem", function(self)
        function self:GetAtlas()
            self.atlas = self.atlasname or GetInventoryItemAtlas(self:GetImage())
            return self.atlas
        end
    end)
end

local function CheckExtension(atlas)
    return atlas:find(".xml") and atlas or atlas..".xml"
end

local function LoadAsset(assets_table, ...)
    table.insert(assets_table, Asset(...))
end

------------------------------------------------------------------------------------

--> Client function:

---Adds a global inventory items atlas, compatible with `mini signs`, `crafts`, `ingredients` and `shelves`.
---
---@param atlas_path string -> The xml file path.
---@param assets_table? table -> The "Assets" table, to load the atlas assets. Not required.
---`Example:`AddInventoryItemAtlas(`"images/inventoryimages.xml", Assets`)
---
------------------------------------------------------------------------------
function _G.AddInventoryItemAtlas(atlas_path, assets_table)
    assert(type(atlas_path) == "string", "[API]: The param 'atlas_path' must be a string.")
    assert(type(assets_table) == "table", "[API]: The param 'assets_table' must be a table.")
    
    local atlas = _G.resolvefilepath(CheckExtension(atlas_path))
    table.insert(inventoryItemAtlasses, atlas)

    if assets_table then 
        LoadAsset(assets_table, "ATLAS", atlas_path)
        LoadAsset(assets_table, "IMAGE", atlas_path:gsub(".xml", ".tex"))
        LoadAsset(assets_table,"ATLAS_BUILD", atlas_path, 256)
    end
end