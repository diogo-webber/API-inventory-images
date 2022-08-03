
--  ================================================================== --
-- |      Library Designed by Leonidas IV  - Copyright 2022-2022      |
--  ================================================================== --

local API_VERSION = "1.2"

------------------------------------------------------------------------------------

local _G = GLOBAL

local HAMenabled = _G.IsDLCEnabled(_G.PORKLAND_DLC)

local function v_number(v)
    local v = v:gsub("%.", "")
    return _G.tonumber(v) or 0 
end

local API_loaded = _G.pcall(function() return _G.TheInvImagesAPI end)
local TheInvImagesAPI = API_loaded and _G.TheInvImagesAPI or {}


if TheInvImagesAPI.version then
    if v_number(API_VERSION) <= v_number(TheInvImagesAPI.version) then
        env.AddInventoryItemAtlas = _G.AddInventoryItemAtlas --> Make the Fn be in the mod env too.
        table.insert(TheInvImagesAPI.mods_using, KnownModIndex:GetModFancyName(modname))
        return -- Load only the latest version ;)
    end
end

------------------------------------------------------------------------------------

TheInvImagesAPI.version = API_VERSION
TheInvImagesAPI.mods_using = TheInvImagesAPI.mods_using or {}
TheInvImagesAPI.atlasLookup = TheInvImagesAPI.atlasLookup or {}

table.insert(TheInvImagesAPI.mods_using, KnownModIndex:GetModFancyName(modname))

------------------------------------------------------------------------------------

local io = _G.require("io")

local function ProcessAtlas(atlas)
    local success, file = _G.pcall(io.open, atlas)
    _G.assert(success, '[API]: The atlas "'..atlas..'" can not be found.')

    local xml = file:read("*all")
    file:close()

    local images = xml:gmatch('<Element name="(.-)"')

    for tex in images do
        TheInvImagesAPI.atlasLookup[tex] = atlas --> Cache the textures.
    end
end

------------------------------------------------------------------------------------

local function CheckExtension(atlas, ext)
    return atlas:gsub(ext, "")..ext
end

local function LoadAsset(assets, ...)
    table.insert(assets, Asset(...))
end

local function AssertType(var, type_, param)
    _G.assert(type(var) == type_, ('[API]: The param "%s" must be a "%s".'):format(param, type_))
end

---Adds a global inventory items atlas, compatible with `mini signs`, `crafts`, `ingredients` and `shelves`.
---
---@param atlas_path string -> The xml file path.
---@param assets_table? table -> The "Assets" table, to load the atlas assets. Not required.
---`Example:`AddInventoryItemAtlas(`"images/inventoryimages.xml", Assets`)
---
------------------------------------------------------------------------------
function _G.AddInventoryItemAtlas(atlas_path, assets_table)
    AssertType(atlas_path, "string", "atlas_path")
    
    local atlas_path = CheckExtension(atlas_path, ".xml")
    local atlas = _G.resolvefilepath(atlas_path)

    ProcessAtlas(atlas)
    
    if assets_table then 
        AssertType(assets_table, "table", "assets_table")

        LoadAsset(assets_table, "ATLAS", atlas_path)
        LoadAsset(assets_table, "IMAGE", atlas_path:gsub(".xml", ".tex"))
        LoadAsset(assets_table, "ATLAS_BUILD", atlas_path, 256)
    end
end

------------------------------------------------------------------------------------

if HAMenabled then ProcessAtlas("images/inventoryimages_2.xml") end

-- Make the fns be in the mod env too.
env.AddInventoryItemAtlas = _G.AddInventoryItemAtlas

_G.TheInvImagesAPI = TheInvImagesAPI

------------------------------------------------------------------------------------

    --> Implementation:

-- A re-implementation of GetInventoryItemAtlas
function _G.GetInventoryItemAtlas(imagename) --> You don't need to call this
    return TheInvImagesAPI.atlasLookup[imagename] or "images/inventoryimages.xml"
end

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
    local default_atlas = "images/inventoryimages.xml"

    local atlas = GetInventoryItemAtlas(image)
    local pre_atlas = pre_atlas and _G.resolvefilepath(pre_atlas) or nil

    return atlas == default_atlas and pre_atlas or atlas
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