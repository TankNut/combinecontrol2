local PANEL = {}

function PANEL:Init()
	self.ModelPanel = self:Add("CC_CharacterModel")
	self.ModelPanel:DockMargin(10, 0, 0, 0)
	self.ModelPanel:Dock(RIGHT)
	self.ModelPanel:SetWide(250)
	self.ModelPanel:SetAllowManipulation(true)
	self.ModelPanel:SetBaseYaw(-20)
	self.ModelPanel:SetPlayer(lp)

	self.InventoryPanel = self:Add("CC_ItemList")
	self.InventoryPanel:Dock(FILL)

	self.InventoryPanel:Receiver("TakeItem", function(_, icons, dropped)
		if not dropped then
			return
		end

		icons[1]:GetItem():RunAction(lp, "Take")
	end)

	self.InventoryPanel.OnIconAdded = function(_, icon)
		icon:Droppable("StoreItem")
	end

	self.InventoryPanel:Populate(lp:GetInventory())
end

derma.DefineControl("CC_PlayerMenu_Inventory", "", PANEL, "Panel")
