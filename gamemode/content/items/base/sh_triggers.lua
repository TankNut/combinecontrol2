function ITEM:OnLoaded()
end

function ITEM:OnRemove()
	if CLIENT then
		self:RemovePanels()
	end
end

-- Removed from an inventory, called before it actually happens
function ITEM:InventoryRemoved(inventory)
	-- Clear equipment
	-- Delete icons(?)
	-- Prompt inventory update
end

-- Added to an inventory, called after it happens
function ITEM:InventoryAdded(inventory)
	-- Prompt inventory update
end
