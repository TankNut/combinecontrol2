local INVENTORY = CustomMetaTable("Inventory")

function INVENTORY:FindItem(class, temporary)
	for _, item in pairs(self.Items) do
		if temporary != nil and item:IsTemporaryItem() != temporary then
			continue
		end

		if item.ClassName == class then
			return item
		end
	end
end
