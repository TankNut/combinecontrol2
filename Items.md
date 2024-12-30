- SetInventory is never used during load, only when MOVING items

# CLIENT
MOVING FROM 'NOWHERE' INTO VIEW
- Item pops into existence without a location
- `ITEM:SetInventory()` into target inventory
  - `ITEM:InventoryAdded()` is called

MOVING FROM VIEW INTO VIEW
- `ITEM:SetInventory()` into target inventory
  - `ITEM:InventoryRemoved()` is called
  - `ITEM:InventoryAdded()` is called

MOVING FROM VIEW INTO 'NOWHERE'/REMOVAL
- `ITEM:SetInventory()` is called with `nil`
  - `ITEM:InventoryRemoved()` is called
- Once it stops having a location `ITEM:Remove()` is called

LOADING INVENTORIES
- Inventory is created on the client
- Items are loaded using `INVENTORY:LoadItems()` and only have `INVENTORY:AddItem()` called, no SetInventory
- `ITEM:OnLoaded()` is called
  - Check equipment validity

UNLOADING INVENTORIES
- `ITEM:Remove()` is called
- Inventory is removed

# PERMISSION TYPES
- CanInteractWithItem
  - Basic check for whether you can interact with something directly (e.g. configuring radios, dropping/destroying/equipping)
  - Only allows items in INV_PLAYER belonging to the player
- CanDropItem
  - CanInteractWithItem check
  - Calls into ITEM:CanDrop
- CanDestroyItem
  - CanInteractWithItem check
  - Calls into ITEM:CanDestroy
- CanEquipItem
  - CanInteractWithItem check
  - Checks for whether the item is already equipped
  - Checks for whether there's any equipment slots that can be used
  - Calls into ITEM:CanEquip
- CanUseEquipmentSlot
  - Checks for whether the player even has that equipment slot
  - If occupied, checks whether the item occupying that equipment slot can be unequipped
- CanUnequipItem
  - CanInteractWithItem check
  - Checks for whether the item is actually equipped
  - Calls into ITEM:CanUnequip (vort shackles)
- CanOpenItemContainer
  - CanInteractWithItem check
  - Calls into ITEM:CanSeachContents (fake rations, locked containers)
- CanTakeItem
  - If the item's inventory is INV_ITEM
    - Runs CanOpenItemContainer
- CanStoreItem
  - If the item's inventory is INV_ITEM
    - Checks for whether we're trying to store an item in itself
    - Runs CanOpenItemContainer
  - Calls into ITEM:CanStore (preventing large items being put into small containers?)
