netstream.Hook("AddItem", function(class, id, data, inventory)
	Item.Instance(class, id, data):SetInventory(Inventory.Get(inventory))
end)

netstream.Hook("MoveItem", function(id, inventory)
	Item.Get(id):SetInventory(Inventory.Get(inventory))
end)

netstream.Hook("RemoveItem", function(id)
	local item = Item.Get(id)

	item:SetInventory(nil)
	item:Remove()
end)

netstream.Hook("ItemData", function(id, key, val)
	Item.Get(id):SetData(key, val)
end)
