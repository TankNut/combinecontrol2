local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 500)

	self:SetToggleKey("gm_showspare2")
	self:SetCloseOnPause(true)
	self:SetTopBar("Admin Menu")

	self:MakePopup()
	self:Center()
end

derma.DefineControl("GUI_AdminMenu", "", PANEL, "CC_BaseMenu")

GUI.Register("AdminMenu", function()
	local instance = vgui.Create("GUI_AdminMenu")

	hook.Run("PopulateAdminMenu", instance)

	instance:Populate()

	return instance
end, true)

function GM:PopulateAdminMenu(panel)
	panel:AddMenu(1, "Tools", "CC_AdminMenu_Tools", nil, true)
end
