local PANEL = {}

function PANEL:Init()
	self:SetSkin("CombineControl")
end

derma.DefineControl("GUI_InventoryPopup", "", PANEL, "DFrame")

GUI.Register("InventoryPopup", function(storeType, storeRef, items)
	local panel = vgui.Create("GUI_InventoryPopup")

	return panel
end, true)
