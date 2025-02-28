local TOCNAME, _ = ...
local BOM = BuffomatAddon ---@type BuffomatAddon

---@class BomItemCacheModule
---@field cacheChanged boolean Set to true on item query callbacks
---@field cache table<number|string, BomItemCacheElement> Stores arg to results mapping for GetItemInfo
local itemCacheModule = BuffomatModule.DeclareModule("ItemCache") ---@type BomItemCacheModule
itemCacheModule.cache = {}

---@class BomItemCacheElement
---@field itemName string
---@field itemLink string Printable colored clickable item link
---@field itemRarity number 0=poor, 1=normal, 2=uncommon, 3=rare ... etc
---@field itemLevel number
---@field itemMinLevel number
---@field itemType string One of "Armor", "Consumable", "Container", ... see Wiki "ItemType"
---@field itemSubType string Same as itemType
---@field itemStackCount number
---@field itemEquipLoc string "" or a constant INVTYPE_HEAD for example
---@field itemTexture string|number Texture or icon id
---@field itemSellPrice number Copper price for the item

---Calls GetItemInfo and saves the results, or not (if nil was returned)
---@param arg number|string
---@return BomItemCacheElement|nil
function BOM.GetItemInfo(arg)
  if itemCacheModule.cache[arg] ~= nil then
    --print("Cached item response for ", arg)
    return itemCacheModule.cache[arg]
  end

  local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType
  , itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(arg)
  if itemName == nil then
    return nil
  end

  local cacheItem = {} ---@type BomItemCacheElement
  cacheItem.itemName = itemName
  cacheItem.itemLink = itemLink
  cacheItem.itemRarity = itemRarity
  cacheItem.itemLevel = itemLevel
  cacheItem.itemMinLevel = itemMinLevel
  cacheItem.itemType = itemType
  cacheItem.itemSubType = itemSubType
  cacheItem.itemStackCount = itemStackCount
  cacheItem.itemEquipLoc = itemEquipLoc
  cacheItem.itemTexture = itemTexture
  cacheItem.itemSellPrice = itemSellPrice

  --print("Added to cache item info for ", arg)
  itemCacheModule.cache[arg] = cacheItem
  return cacheItem
end

function itemCacheModule:LoadItem(itemId)
  local itemMixin = Item:CreateFromItemID(itemId)

  local itemLoaded = function()
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType
    , itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemId)
    if itemName == nil then
      return
    end

    local cacheItem = {} ---@type BomItemCacheElement
    cacheItem.itemName = itemMixin:GetItemName()
    cacheItem.itemLink = itemMixin:GetItemLink()
    cacheItem.itemRarity = itemMixin:GetItemQuality()
    cacheItem.itemLevel = itemLevel
    cacheItem.itemMinLevel = itemMinLevel
    cacheItem.itemType = itemType
    cacheItem.itemSubType = itemSubType
    cacheItem.itemStackCount = itemStackCount
    cacheItem.itemEquipLoc = itemEquipLoc
    cacheItem.itemTexture = itemMixin:GetItemIcon()
    cacheItem.itemSellPrice = itemSellPrice

    itemCacheModule.cache[itemId] = cacheItem
    itemCacheModule.cacheChanged = true
    BOM.ForceUpdate = true
  end

  if C_Item.DoesItemExistByID(itemId) then
    itemMixin:ContinueOnItemLoad(itemLoaded)
  end
end