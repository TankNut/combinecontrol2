netstream.Hook("CreateInventory", function(id, storeType, storeID, parent, items)
	Inventory.Create(id, storeType, storeID, parent):LoadItems(items)
end)

netstream.Hook("RemoveInventory", function(id)
	Inventory.Get(id):Remove()
end)
