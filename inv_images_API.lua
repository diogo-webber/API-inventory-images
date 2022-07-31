
--  ================================================================== --
-- |      Library Designed by Leonidas IV  - Copyright 2022-2022      |
--  ================================================================== --

local API_VERSION = "1.0.4"

------------------------------------------------------------------------------------

local _G = GLOBAL

local GLOBAL_VERSION = _G.rawget(_G, INV_IMAGES_API_VERSION)

local function v_number(v) return _G.tonumber(v:gsub("%.", "")) or 0 end

if GLOBAL_VERSION then
    if v_number(API_VERSION) < v_number(GLOBAL_VERSION) then
        AddInventoryItemAtlas = _G.AddInventoryItemAtlas --> Make the Fn be in the mod env too.
        return -- Load only the latest version ;)
    end
end

_G.INV_IMAGES_API_VERSION = API_VERSION

------------------------------------------------------------------------------------

--> Abstractions:

local HAMenabled = _G.IsDLCEnabled(_G.PORKLAND_DLC)

local inventoryItemAtlasses = HAMenabled and {"images/inventoryimages_2.xml"} or {}

-- This is global to permit direct inserts in the look up.
_G.inventoryItemAtlasLookup = {}

local io = _G.require("io")

------------------------------------------------------------------------------------

local function ProcessAtlas(atlas, imagename)
    local valid_atlas = nil

    if HAMenabled then
        if _G.TheSim:AtlasContains(atlas, imagename) then
            _G.inventoryItemAtlasLookup[imagename] = atlas
            return atlas
        end
    end

    local success, file = _G.pcall(io.open, atlas)
    _G.assert(success, '[API]: The atlas "'..atlas..'" can not be found.')

    local xml = file:read("*all")
    file:close()

    local images = xml:gmatch('<Element name="(.-)"')

    for tex in images do
        _G.inventoryItemAtlasLookup[tex] = atlas --> Cache the textures.

        if imagename == tex then
            valid_atlas = atlas
        end
    end

    return valid_atlas
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

------------------------------------------------------------------------------------

local GetInventoryItemAtlas = _G.GetInventoryItemAtlas

local function HookOnDrawnFn(inst)
    local _OnDrawnFn = inst.components.drawable.ondrawnfn
    inst.components.drawable.ondrawnfn = function(inst, image, src)
        _OnDrawnFn(inst, image, src)
        
        local atlas = GetInventoryItemAtlas(image..".tex")
        if image ~= nil and atlas then
            inst.AnimState:OverrideSymbol("SWAP_SIGN", atlas, image..".tex")
        end
    end
end

AddPrefabPostInit("minisign", HookOnDrawnFn)
AddPrefabPostInit("minisign_drawn", HookOnDrawnFn)

------------------------------------------------------------------------------------

local function ChangedGetAtlas(image, pre_atlas)
    local deflault_atlas = "images/inventoryimages.xml"

    local atlas = GetInventoryItemAtlas(image)
    local pre_atlas = pre_atlas and resolvefilepath(pre_atlas) or nil

    return atlas == deflault_atlas and pre_atlas or atlas
end

function _G.Ingredient:GetAtlas(imagename)
    self.atlas = ChangedGetAtlas(imagename, self.atlas)
    return self.atlas
end

function _G.Recipe:GetAtlas()
    self.atlas = ChangedGetAtlas(self.image, self.atlas)
    return self.atlas
end

AddComponentPostInit("inventoryitem", function(self)
    function self:GetAtlas()
        self.atlas = ChangedGetAtlas(self:GetImage(), self.atlasname)
        return self.atlas
    end
end)

------------------------------------------------------------------------------------

local function CheckExtension(atlas)
    return atlas:find(".xml") and atlas or atlas..".xml"
end

local function LoadAsset(assets_table, ...)
    table.insert(assets_table, Asset(...))
end

local function AssertType(var, type_, param)
    _G.assert(type(var) == type_, ('[API]: The param "%s" must be a "%s".'):format(param, type_))
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
    AssertType(atlas_path, "string", "atlas_path")
    
    local atlas = _G.resolvefilepath(CheckExtension(atlas_path))
    table.insert(inventoryItemAtlasses, atlas)
    
    if assets_table then 
        AssertType(assets_table, "table", "assets_table")

        LoadAsset(assets_table, "ATLAS", atlas_path)
        LoadAsset(assets_table, "IMAGE", atlas_path:gsub(".xml", ".tex"))
        LoadAsset(assets_table, "ATLAS_BUILD", atlas_path, 256)
    end
end

-- Make the Fn be in the mod env too.
AddInventoryItemAtlas = _G.AddInventoryItemAtlas