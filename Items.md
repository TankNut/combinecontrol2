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
