local text = [[<giant><b>Inventory</b></giant>
	Your character has an inventory that contains your items and any equipment you're carrying. Each item has it's own weight and carrying too much will prevent you from picking up anything else. Equipment will weigh less when actively equipped.
	
	Items can have extra actions which are available by either double-clicking the item to bring up the examine panel, or by rightclicking them in your inventory.

	Bags and other similar items can include their own inventories, accessible through the item's actions. While you cannot interact with items stored inside of these inventories, they will often weigh less. Doubly so if the bag itself is equipped.

<giant><b>Stashes</b></giant>
	Depending on your character type, you might be able to place down a stash.

	Stashes are a secondary inventory attached to your character that represents a safe place for you to store your items such as a personal locker, chest or off-map location. You can place your stash anywhere you want and access it whenever you're nearby.

	While you can place your stash anywhere, moving it will prevent you from accessing it for some time. Even so, using your stash in an unrealistic or abusive way (e.g. using it as a way to hide items you would otherwise be carrying on you) will likely get you punished by an admin.
]]

hook.Add("PopulateHelpMenu", "inventory", function(panel)
	panel:AddMenu(5, "Inventory", text)
end)
