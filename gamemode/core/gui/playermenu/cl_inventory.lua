local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self.ModelPanel = self:Add("CC_CharacterModel")
	self.ModelPanel:DockMargin(10, 0, 0, 0)
	self.ModelPanel:Dock(RIGHT)
	self.ModelPanel:SetWide(250)
	self.ModelPanel:SetAllowManipulation(true)
	self.ModelPanel:SetBaseYaw(-20)
	self.ModelPanel:SetPlayer(lp)

	self.InventoryPanel = self:Add("CC_ItemList")
	self.InventoryPanel:Dock(FILL)
	self.InventoryPanel:Populate(lp:GetInventory())
end

derma.DefineControl("CC_PlayerMenu_Inventory", "", PANEL, "DPanel")
