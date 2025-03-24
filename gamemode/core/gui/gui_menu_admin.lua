-- Used in both gui_admin_characters and gui_admin_players.
gameevent.Listen("player_disconnect")

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
	panel:AddMenu(2, "Players", "CC_AdminMenu_Players")
	panel:AddMenu(3, "Characters", "CC_AdminMenu_Characters")
	panel:AddMenu(4, "Ambience", function() return print("TODO") end)
	panel:AddMenu(5, "Logs", "CC_AdminMenu_Logs")
	panel:AddMenu(6, "Bans", "CC_AdminMenu_Bans")
	panel:AddMenu(7, "Admins", "CC_AdminMenu_Roster")
end
