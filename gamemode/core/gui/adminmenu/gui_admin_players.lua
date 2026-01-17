local toolTrust = {
	[TOOLTRUST_BANNED] = "Banned",
	[TOOLTRUST_UNTRUSTED] = "Untrusted",
	[TOOLTRUST_TRUSTED] = "Trusted",
	[TOOLTRUST_ADVANCED] = "Advanced",
}

local PANEL = {}

function PANEL:Init()
	self.SelectedPlayer = nil

	self.List = self:Add("DListView")
	self.List:SetMultiSelect(false)
	self.List:SetWide(ui.Scale(250))
	self.List:AddColumn("Steam Name"):SetFixedWidth(ui.Scale(100))
	self.List:AddColumn("Character Name")
	self.List.Cache = {}

	hook.Add("OnVisibleRPNameChanged", self, function(_, ply, old, new, loaded)
		self:UpdatePlayerListing(ply)
	end)

	hook.Add("player_disconnect", self, function(_, data)
		local ply = Player(data.userid)
		local line = self.List.Cache[ply:SteamID()]

		if not line then
			return
		else
			self.List.Cache[ply:SteamID()] = nil
		end

		self.List:RemoveLine(line:GetID())

		if self.SelectedPlayer == ply then
			self:UnselectPlayer()
		end
	end)

	self.List.OnRowSelected = function(_, _, row)
		if self.SelectedPlayer != row.Player then
			self:UnselectPlayer()
		end

		self:SelectPlayer(row.Player)
	end

	-- Kicks and Bans
	self.KickBanLabel = self:CreateLabel("Kick or Ban", true, ui.Scale(250))
	self.ReasonLabel = self:CreateLabel("Reason", false, ui.Scale(65))
	self.DurationLabel = self:CreateLabel("Duration", false, ui.Scale(65))

	self.ReasonEntry = self:CreateTextEntry()
	self.DurationEntry = self:CreateTextEntry(ui.Scale(75))

	self.KickButton = self:CreateButton("Kick", ui.Scale(105), function(ply)
		local reason = string.Trim(self.ReasonEntry:GetValue())

		if #reason > 0 then
			RunConsoleCommand("rpa_kick", ply:SteamID(), reason)
		else
			RunConsoleCommand("rpa_kick", ply:SteamID())
		end

		self.ReasonEntry:SetValue("")
	end)
	self.BanButton = self:CreateButton("Ban", ui.Scale(105), function(ply)
		local reason = string.Trim(self.ReasonEntry:GetValue())
		local duration = string.Trim(self.DurationEntry:GetValue())

		if #duration == 0 then
			lp:SendChat("ERROR", "Enter a duration in order to submit a normal ban")

			return -- You know, just click permaban. :smilecat:
		end

		if #reason > 0 then
			RunConsoleCommand("rpa_ban", ply:SteamID(), duration, reason)
		else
			RunConsoleCommand("rpa_ban", ply:SteamID(), duration)
		end

		self.ReasonEntry:SetValue("")
		self.DurationEntry:SetValue("")
	end)
	self.PermabanButton = self:CreateButton("Permaban", ui.Scale(105), function(ply)
		local reason = string.Trim(self.ReasonEntry:GetValue())

		if #reason > 0 then
			RunConsoleCommand("rpa_ban", ply:SteamID(), "0", reason)
		else
			RunConsoleCommand("rpa_ban", ply:SteamID(), "0")
		end

		self.ReasonEntry:SetValue("")
	end)

	-- Quick Commands
	self.QuickLabel = self:CreateLabel("Quick Commands", true, ui.Scale(205))
	self.TeleportLabel = self:CreateLabel("Teleporting", false, ui.Scale(80))
	self.ActionsLabel = self:CreateLabel("Actions", false, ui.Scale(80))
	self.MiscellaniousLabel = self:CreateLabel("Miscellaneous", false, ui.Scale(80))
	self.ScaleLabel = self:CreateLabel("Scale", false, ui.Scale(80))

	self.GotoButton = self:CreateButton("Goto Player", ui.Scale(105), function(ply)
		RunConsoleCommand("rpa_goto", ply:SteamID())
	end)

	self.BringButton = self:CreateButton("Bring Player", ui.Scale(105), function(ply)
		RunConsoleCommand("rpa_bring", ply:SteamID())
	end)

	self.KillButton = self:CreateButton("Kill Player", ui.Scale(105), function(ply)
		RunConsoleCommand("rpa_kill", ply:SteamID())
	end)
	self.SlapButton = self:CreateButton("Slap Player", ui.Scale(105), function(ply)
		RunConsoleCommand("rpa_slap", ply:SteamID())
	end)
	self.HealButton = self:CreateButton("Heal Player", ui.Scale(105), function(ply)
		RunConsoleCommand("rpa_heal", ply:SteamID())
	end)

	self.CopySteamIDButton = self:CreateButton("Copy SteamID", ui.Scale(105), function(ply)
		lp:SendChat("NOTICE", string.format("Copied %s's Steam ID (%s) to your clipboard", ply:Nick(), ply:SteamID()))

		SetClipboardText(ply:SteamID())
	end)
	self.ListCharactersButton = self:CreateButton("List Characters", ui.Scale(105), function(ply)
		lp:SendChat("NOTICE", string.format("Sent %s's character list to your console", ply:Nick()))

		RunConsoleCommand("rpa_character_list", ply:SteamID())
	end)

	self.EnterScale = self:CreateTextEntry(ui.Scale(105))
	self.EnterScale:SetNumeric(true)
	self.ApplyScaleButton = self:CreateButton("Apply", ui.Scale(50), function(ply)
		local value = self.EnterScale:GetFloat()

		if value then
			RunConsoleCommand("rpa_player_scale", ply:SteamID(), value)
		end
	end)

	-- Permissions
	self.PermissionsLabel = self:CreateLabel("User Permissions", true, ui.Scale(250))
	self.MutedLabel = self:CreateLabel("OOC Muted", false, ui.Scale(80))
	self.ToolTrustLabel = self:CreateLabel("Tool Trust", false, ui.Scale(80))

	self.MutedCheckBox = self:Add("DCheckBox")
	self.MutedCheckBox:SetDisabled(true)
	self.MutedCheckBox.OnChange = function(_, val)
		local ply = self.SelectedPlayer

		if ply then
			RunConsoleCommand("rpa_ooc_mute", ply:SteamID(), tostring(val))
		end
	end

	hook.Add("OnOOCMutedChanged", self, function(_, ply, old, new, loaded)
		if self.SelectedPlayer == ply then
			self.MutedCheckBox:SetChecked(new == 1)
		end
	end)

	self.ToolTrustDropdown = self:Add("DComboBox")
	self.ToolTrustDropdown:SetWide(ui.Scale(100))
	self.ToolTrustDropdown:SetSortItems(false)
	self.ToolTrustDropdown:SetDisabled(true)

	for enum, name in pairs(toolTrust) do
		self.ToolTrustDropdown:AddChoice(name, enum)
	end

	hook.Add("OnToolTrustChanged", self, function(_, ply, old, new, loaded)
		if self.SelectedPlayer == ply then
			self.ToolTrustDropdown:ChooseOptionID(ply:ToolTrust() + 1)
		end
	end)

	self.ApplyToolTrustButton = self:CreateButton("Apply", ui.Scale(50), function(ply)
		local name = self.ToolTrustDropdown:GetSelected()

		RunConsoleCommand("rpa_player_tooltrust", ply:SteamID(), string.lower(name))
	end)

	self:PopulatePlayerList()
end

function PANEL:PopulatePlayerList()
	for _, ply in player.Iterator() do
		if not ply:HasCharacter() then
			continue
		end

		self:UpdatePlayerListing(ply)
	end
end

function PANEL:UpdatePlayerListing(ply)
	local line = self.List.Cache[ply:SteamID()]

	if not line then
		line = self.List:AddLine()
		line.Player = ply
	end

	line:SetValue(1, ply:Nick())
	line:SetValue(2, ply:VisibleRPName())
	line:SetTooltipPanelOverride("CC_Tooltip")
	line:SetTooltip(string.format([[<b>Steam ID:</b> <dark>%s</dark>
<b>Steam Name:</b> <dark>%s</dark>
<b>Character Name:</b> <dark>%s</dark>]], ply:SteamID(), ply:Nick(), ply:VisibleRPName()))

	self.List.Cache[ply:SteamID()] = line
end

function PANEL:SelectPlayer(ply)
	self.SelectedPlayer = ply

	if lp:CanTarget(ply, true) then
		self.KickButton:SetDisabled(false)
		self.BanButton:SetDisabled(false)
		self.PermabanButton:SetDisabled(false)
	end

	self.GotoButton:SetDisabled(false)
	self.BringButton:SetDisabled(false)
	self.KillButton:SetDisabled(false)
	self.SlapButton:SetDisabled(false)
	self.HealButton:SetDisabled(false)
	self.CopySteamIDButton:SetDisabled(false)
	self.ListCharactersButton:SetDisabled(false)
	self.EnterScale:SetValue(ply:Scale())
	self.ApplyScaleButton:SetDisabled(false)

	if lp:CanTarget(ply) then
		self.ToolTrustDropdown:ChooseOptionID(ply:ToolTrust() + 1)
		self.ToolTrustDropdown:SetDisabled(false)
		self.ApplyToolTrustButton:SetDisabled(false)

		self.MutedCheckBox:SetChecked(ply:OOCMuted() == 1)
		self.MutedCheckBox:SetDisabled(false)
	end
end

function PANEL:UnselectPlayer(ply)
	for _, panel in pairs(self:GetChildren()) do
		if panel:GetName() == "DButton" then
			panel:SetDisabled(true)
		end
	end

	self.ToolTrustDropdown:SetValue("")
	self.ToolTrustDropdown:SetDisabled(true)

	self.MutedCheckBox:SetChecked(false)
	self.MutedCheckBox:SetDisabled(true)

	self.EnterScale:SetValue("")

	self.SelectedPlayer = nil
end

function PANEL:CreateLabel(text, bold, wide)
	local label = self:Add("DLabel")

	label:SetFont("CombineControl.LabelMedium" .. (bold and "Bold" or ""))
	label:SetWide(wide or ui.Scale(150))
	label:SetText(text)

	return label
end

function PANEL:CreateButton(text, wide, doClick)
	local button = self:Add("DButton")

	button:SetText(text)
	button:SetWide(wide or ui.Scale(150))
	button:SetDisabled(true)

	button.DoClick = function(panel)
		if not self.SelectedPlayer then
			return
		end

		doClick(self.SelectedPlayer)
	end

	return button
end

function PANEL:CreateTextEntry(wide)
	local entry = self:Add("DTextEntry")

	entry:SetWide(wide or ui.Scale(150))
	entry:SetTall(22)

	return entry
end

function PANEL:PerformLayout(w, h)
	self.List:AlignLeft()
	self.List:StretchToParent(nil, nil, nil, 0)

	-- Kicks and Bans
	self.KickBanLabel:MoveRightOf(self.List, ui.Scale(10))
	self.KickBanLabel:AlignTop()

	self.ReasonLabel:MoveRightOf(self.List, ui.Scale(10))
	self.ReasonLabel:MoveBelow(self.KickBanLabel, ui.Scale(5))

	self.KickButton:AlignRight()
	self.KickButton:MoveBelow(self.KickBanLabel, ui.Scale(5))

	self.ReasonEntry:MoveRightOf(self.ReasonLabel, 0)
	self.ReasonEntry:MoveBelow(self.KickBanLabel, ui.Scale(5))
	self.ReasonEntry:StretchRightTo(self.KickButton, ui.Scale(5))

	self.DurationLabel:MoveRightOf(self.List, ui.Scale(10))
	self.DurationLabel:MoveBelow(self.ReasonLabel, ui.Scale(5))

	self.DurationEntry:MoveRightOf(self.DurationLabel, 0)
	self.DurationEntry:MoveBelow(self.ReasonLabel, ui.Scale(5))

	self.PermabanButton:MoveBelow(self.ReasonLabel, ui.Scale(5))
	self.PermabanButton:AlignRight()

	self.BanButton:MoveLeftOf(self.PermabanButton, ui.Scale(5))
	self.BanButton:MoveBelow(self.ReasonLabel, ui.Scale(5))

	-- General Management
	self.QuickLabel:MoveRightOf(self.List, ui.Scale(10))
	self.QuickLabel:MoveBelow(self.DurationLabel, ui.Scale(10))

	self.TeleportLabel:MoveRightOf(self.List, ui.Scale(10))
	self.TeleportLabel:MoveBelow(self.QuickLabel, ui.Scale(5))

	self.GotoButton:MoveRightOf(self.TeleportLabel, ui.Scale(5))
	self.GotoButton:MoveBelow(self.QuickLabel, ui.Scale(5))

	self.BringButton:MoveRightOf(self.GotoButton, ui.Scale(5))
	self.BringButton:MoveBelow(self.QuickLabel, ui.Scale(5))

	self.ActionsLabel:MoveRightOf(self.List, ui.Scale(10))
	self.ActionsLabel:MoveBelow(self.TeleportLabel, ui.Scale(5))

	self.KillButton:MoveRightOf(self.ActionsLabel, ui.Scale(5))
	self.KillButton:MoveBelow(self.TeleportLabel, ui.Scale(5))

	self.SlapButton:MoveRightOf(self.KillButton, ui.Scale(5))
	self.SlapButton:MoveBelow(self.TeleportLabel, ui.Scale(5))

	self.HealButton:MoveRightOf(self.SlapButton, ui.Scale(5))
	self.HealButton:MoveBelow(self.TeleportLabel, ui.Scale(5))

	self.MiscellaniousLabel:MoveRightOf(self.List, ui.Scale(10))
	self.MiscellaniousLabel:MoveBelow(self.ActionsLabel, ui.Scale(5))

	self.CopySteamIDButton:MoveRightOf(self.MiscellaniousLabel, ui.Scale(5))
	self.CopySteamIDButton:MoveBelow(self.ActionsLabel, ui.Scale(5))

	self.ListCharactersButton:MoveRightOf(self.CopySteamIDButton, ui.Scale(5))
	self.ListCharactersButton:MoveBelow(self.ActionsLabel, ui.Scale(5))

	self.ScaleLabel:MoveRightOf(self.List, ui.Scale(10))
	self.ScaleLabel:MoveBelow(self.MiscellaniousLabel, ui.Scale(5))

	self.EnterScale:MoveRightOf(self.ScaleLabel, ui.Scale(5))
	self.EnterScale:MoveBelow(self.MiscellaniousLabel, ui.Scale(5))

	self.ApplyScaleButton:MoveRightOf(self.EnterScale, ui.Scale(5))
	self.ApplyScaleButton:MoveBelow(self.MiscellaniousLabel, ui.Scale(5))

	-- Permissions
	self.PermissionsLabel:MoveRightOf(self.List, ui.Scale(10))
	self.PermissionsLabel:MoveBelow(self.ScaleLabel, ui.Scale(10))

	self.MutedLabel:MoveRightOf(self.List, ui.Scale(10))
	self.MutedLabel:MoveBelow(self.PermissionsLabel, ui.Scale(5))

	self.MutedCheckBox:MoveRightOf(self.MutedLabel)
	self.MutedCheckBox:SetY(self.MutedLabel:GetY() + ui.Scale(3))

	self.ToolTrustLabel:MoveRightOf(self.List, ui.Scale(10))
	self.ToolTrustLabel:MoveBelow(self.MutedLabel, ui.Scale(5))

	self.ToolTrustDropdown:MoveRightOf(self.ToolTrustLabel, 0)
	self.ToolTrustDropdown:MoveBelow(self.MutedLabel, ui.Scale(5))

	self.ApplyToolTrustButton:MoveRightOf(self.ToolTrustDropdown, ui.Scale(5))
	self.ApplyToolTrustButton:MoveBelow(self.MutedLabel, ui.Scale(5))
end

vgui.Register("CC_AdminMenu_Players", PANEL, "Panel")
