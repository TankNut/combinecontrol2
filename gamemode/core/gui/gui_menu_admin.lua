local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 500)

	self:SetToggleKey("gm_showspare2")
	self:SetCloseOnPause(true)
	self:SetTopBar("Admin Menu")

	self:MakePopup()
	self:Center()

	hook.Add("OnUserGroupChanged", self, function(_, ply, old, new)
		if lp == ply and not ply:IsAdmin() then
			self:Remove()
		end
	end)
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
	panel:AddMenu(2, "Admin Roster", "CC_AdminMenu_Roster")
end
