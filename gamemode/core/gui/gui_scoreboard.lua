-- Scoreboard entry
local PANEL = {}

AccessorFunc(PANEL, "Alt", "Alt")

function PANEL:Init()
	self.Icon = self:Add("CC_CharacterModel")

	self.Badge = self:Add("DButton")
	self.Badge:Dock(RIGHT)
	self.Badge:SetText("")
	self.Badge.Paint = function() end

	self.Badge.DoClick = function()
		GUI.Open("BadgeList", self.Player)
	end

	self.Examine = self:Add("DButton")
	self.Examine:Dock(FILL)
	self.Examine:SetText("")
	self.Examine.Paint = function() end

	self.Examine.DoClick = function()
		self.Player:Examine()
	end

	self.Examine.DoRightClick = function()
		if not lp:IsAdmin() then
			return
		end

		self:OpenScoreboardCommands()
	end
end

function PANEL:SetPlayer(ply)
	self.Player = ply
	self.Team = ply:Team()

	self.Icon:SetPlayer(ply)
	self.Icon.Zoom = 1
	self.Icon:SetBaseYaw(20)
end

function PANEL:IsInvalid()
	if not IsValid(self.Player) then
		return true
	end

	if self.Player:Team() != self.Team then
		return true
	end

	if not lp:IsAdmin() and self.Hidden then
		return true
	end

	return false
end

function PANEL:OpenScoreboardCommands()
	local actions = Config.Get("ScoreboardCommands")

	if self:IsInvalid() or table.IsEmpty(actions) then
		return
	end

	local dmenu = DermaMenu()

	dmenu:SetSkin("CombineControlNew")
	dmenu:SetPos(gui.MousePos())

	for _, action in ipairs(actions) do
		dmenu:AddOption(action[1], function()
			gui.EnableScreenClicker(false)

			if not IsValid(self.Player) then
				return
			end

			local cmd = isstring(action[2]) and action[2] or action[2](self.Player)

			RunConsoleCommand(cmd, self.Player:SteamID())
		end)
	end

	dmenu:Open()
end

function PANEL:Think()
	self.Hidden = hook.Run("ShouldHidePlayer", self.Player)

	if self:IsInvalid() then
		self:Remove()

		return
	end
end

function PANEL:PerformLayout(w, h)
	self.Icon:SetPos(1, 1)
	self.Icon:SetSize(h - 2, h - 2)

	self.Badge:SetWide(math.max(100, #self.Player:GetBadges() * 18 + 28))
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "ScoreboardEntry", self, w, h)
end

derma.DefineControl("CC_ScoreboardEntry", "", PANEL, "Panel")

-- Scoreboard team
PANEL = {}

AccessorFunc(PANEL, "Team", "Team")

function PANEL:Init()
	self:DockPadding(0, 50, 0, 0)
	self.Players = {}
	self.Empty = false
end

function PANEL:Think()
	local players = team.GetPlayers(self.Team)

	if (#players == 0 and not self.Empty) or (#players > 0 and self.Empty) then
		self:InvalidateLayout()

		return
	end

	table.sort(players, function(a, b) return a:VisibleRPName() < b:VisibleRPName() end)

	local alt = true

	for k, ply in ipairs(players) do
		if not lp:IsAdmin() and hook.Run("ShouldHidePlayer", ply) then
			continue
		end

		local panel = self.Players[ply] or self:AddPlayer(ply)

		panel:SetAlt(alt)

		if panel:GetZPos() != k then
			panel:SetZPos(k)
		end

		alt = not alt
	end
end

function PANEL:AddPlayer(ply)
	local panel = self:Add("CC_ScoreboardEntry")

	panel:Dock(TOP)
	panel:SetTall(60)
	panel:SetPlayer(ply)

	self.Players[ply] = panel

	return panel
end

function PANEL:OnChildRemoved(child)
	self.Players[child.Player] = nil
end

function PANEL:PerformLayout(w, h)
	self.Empty = #team.GetPlayers(self.Team) == 0

	if self.Empty then
		self:SetTall(0)

		return
	end

	h = 50

	for _, v in ipairs(self:GetChildren()) do
		h = h + v:GetTall()
	end

	self:SetTall(h)
end

function PANEL:Paint(w, h)
	local color = Color("cc_normal")

	draw.SimpleText(team.GetName(self.Team), "CombineControl.LabelGiant", 10, 25, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(string.format("%s/%s", #team.GetPlayers(self.Team), player.GetCount()), "CombineControl.LabelGiant", w - 10, 25, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

derma.DefineControl("CC_ScoreboardTeam", "", PANEL, "Panel")

-- Scoreboard
PANEL = {}

local internalTeams = table.Lookup({
	TEAM_CONNECTING, TEAM_UNASSIGNED, TEAM_SPECTATOR
})

function PANEL:Init()
	self:SetSize(620, ScreenScale(200))
	self:DockPadding(0, 50, 0, 0)

	self:MakePopup()
	self:Center()

	self:SetKeyboardInputEnabled(false)

	self.Players = self:Add("DScrollPanel")
	self.Players:Dock(FILL)

	for index, data in pairs(team.GetAllTeams()) do
		if internalTeams[index] then
			continue
		end

		local header = self.Players:Add("CC_ScoreboardTeam")

		header:SetTeam(index)
		header:SetZPos(index)
		header:Dock(TOP)
	end
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Scoreboard", self, w, h)
end

derma.DefineControl("GUI_Scoreboard", "", PANEL, "CC_Frame")

GUI.Register("Scoreboard", function()
	return vgui.Create("GUI_Scoreboard")
end, true)
