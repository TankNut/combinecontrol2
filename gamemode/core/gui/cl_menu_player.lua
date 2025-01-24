local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 500)

	self:SetToggleKey("gm_showspare1")
	self:SetCloseOnPause(true)
	self:SetTopBar("Player Menu")

	self:MakePopup()
	self:Center()
end

derma.DefineControl("GUI_PlayerMenu", "", PANEL, "CC_BaseMenu")

GUI.Register("PlayerMenu", function()
	local instance = vgui.Create("GUI_PlayerMenu")

	hook.Run("PopulatePlayerMenu", instance)

	instance:Populate()

	return instance
end, true)

function GM:PopulatePlayerMenu(panel)
	panel:AddMenu(1, "Description", "CC_PlayerMenu_Description")
	panel:AddMenu(2, "Inventory", "CC_PlayerMenu_Inventory", nil, true)
end
