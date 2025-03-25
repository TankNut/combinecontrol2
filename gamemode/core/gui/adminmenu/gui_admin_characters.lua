local PANEL = {}

function PANEL:Init()
	self.SelectedPlayer = nil
	self.SelectedCharID = nil

	self.List = self:Add("DListView")
	self.List:SetMultiSelect(false)
	self.List:SetWide(250)
	self.List:AddColumn("Steam Name"):SetFixedWidth(100)
	self.List:AddColumn("Character Name")
	self.List.Cache = {}

	hook.Add("OnCharIDChanged", self, function(_, ply, old, new, loaded)
		if ply:HasCharacter() then
			if new != self.SelectedCharID then
				self:UnselectPlayer()
			end

			self:UpdatePlayerListing(ply)
		else
			self:RemovePlayerListing(ply)
		end
	end)

	hook.Add("OnVisibleRPNameChanged", self, function(_, ply, old, new, loaded)
		self:UpdatePlayerListing(ply)
	end)

	hook.Add("player_disconnect", self, function(_, data)
		self:RemovePlayerListing(Player(data.userid))
	end)

	self.List.OnRowSelected = function(_, _, row)
		if self.SelectedPlayer != row.Player then
			self:UnselectPlayer()
		end

		self:SelectPlayer(row.Player)
	end

	-- Basic Information
	self.InformationLabel = self:CreateLabel("Basic Information", true, 250)
	self.NameLabel = self:CreateLabel("Name", false, 60)
	self.FlagLabel = self:CreateLabel("Flag", false, 60)
	self.HiddenLabel = self:CreateLabel("Hidden", false, 60)

	self.EnterName = self:CreateTextEntry()
	self.ApplyName = self:CreateButton("Apply", 105, function(ply)
		local name = string.Trim(self.EnterName:GetValue())

		if #name > 0 then
			RunConsoleCommand("rpa_setcharname", ply:SteamID(), name)
		end
	end)

	self.SelectFlag = self:Add("DComboBox")
	self.SelectFlag:SetWide(100)
	self.SelectFlag:SetSortItems(false)
	self.SelectFlag:SetDisabled(true)

	for enum, flag in pairs(CharacterFlag.List) do
		self.SelectFlag:AddChoice(flag.Name, enum)
	end

	hook.Add("OnCharacterFlagChanged", self, function(_, ply, old, new, loaded)
		if self.SelectedPlayer == ply and self.SelectedCharID == ply:CharID() then
			self.SelectFlag:ChooseOptionID(table.KeyFromValue(self.SelectFlag.Data, new))
		end
	end)

	self.ApplyFlag = self:CreateButton("Apply", 50, function(ply)
		local _, flag = self.SelectFlag:GetSelected()

		RunConsoleCommand("rpa_setcharflag", ply:SteamID(), flag)
	end)

	self.HiddenToggle = self:Add("DCheckBox")
	self.HiddenToggle:SetDisabled(true)
	self.HiddenToggle.OnChange = function(_, val)
		local ply = self.SelectedPlayer

		if ply then
			RunConsoleCommand("rpa_setcharhidden", ply:SteamID(), tostring(val))
		end
	end

	hook.Add("OnCharacterHiddenChanged", self, function(_, ply, old, new, loaded)
		if self.SelectedPlayer == ply and self.SelectedCharID == ply:CharID() then
			self.HiddenToggle:SetChecked(new == 1)
		end
	end)

	-- Appearance Customization
	self.AppearanceLabel = self:CreateLabel("Basic Appearance", true, 250)
	self.ModelLabel = self:CreateLabel("Model", false, 60)
	self.SkinLabel = self:CreateLabel("Skin", false, 60)
	self.ScaleLabel = self:CreateLabel("Scale", false, 60)

	self.EnterModel = self:CreateTextEntry()
	self.ApplyModel = self:CreateButton("Apply", 105, function(ply)
		local model = string.Trim(self.EnterModel:GetValue())

		if #model > 0 then
			RunConsoleCommand("rpa_setcharmodel", ply:SteamID(), model)
		end
	end)

	self.EnterSkin = self:CreateTextEntry(50)
	self.EnterSkin:SetNumeric(true)
	self.ApplySkin = self:CreateButton("Apply", 50, function(ply)
		local value = self.EnterSkin:GetInt()

		if value then
			RunConsoleCommand("rpa_setcharskin", ply:SteamID(), value)
		end
	end)

	self.EnterScale = self:CreateTextEntry(50)
	self.EnterScale:SetNumeric(true)
	self.ApplyScaleTemp = self:CreateButton("Apply Temporarily", 105, function(ply)
		local value = self.EnterScale:GetFloat()

		if value then
			RunConsoleCommand("rpa_setcharscale", ply:SteamID(), value)
		end
	end)
	self.ApplyScalePerm = self:CreateButton("Apply Permanently", 105, function(ply)
		local value = self.EnterScale:GetFloat()

		if value then
			RunConsoleCommand("rpa_setcharscale", ply:SteamID(), value, "true")
		end
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

function PANEL:RemovePlayerListing(ply)
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
	self.SelectedCharID = ply:CharID()

	-- Basic Information
	self.EnterName:SetValue("")
	self.ApplyName:SetDisabled(false)
	self.SelectFlag:ChooseOptionID(table.KeyFromValue(self.SelectFlag.Data, ply:CharacterFlag() or GAMEMODE.DefaultFlag))
	self.SelectFlag:SetDisabled(false)
	self.ApplyFlag:SetDisabled(false)
	self.HiddenToggle:SetChecked(ply:CharacterHidden() == 1)
	self.HiddenToggle:SetDisabled(false)

	-- Basic Appearance
	self.EnterModel:SetValue(ply:GetModel())
	self.ApplyModel:SetDisabled(false)
	self.EnterSkin:SetValue(ply:GetSkin())
	self.ApplySkin:SetDisabled(false)
	self.EnterScale:SetValue(ply:CharacterScale())
	self.ApplyScaleTemp:SetDisabled(false)
	self.ApplyScalePerm:SetDisabled(false)
end

function PANEL:UnselectPlayer(ply)
	for _, panel in pairs(self:GetChildren()) do
		if panel:GetName() == "DButton" then
			panel:SetDisabled(true)
		end
	end

	-- Basic Information
	self.EnterName:SetValue("")
	self.SelectFlag:SetValue("")
	self.SelectFlag:SetDisabled(true)
	self.HiddenToggle:SetChecked(false)
	self.HiddenToggle:SetDisabled(true)

	-- Basic Appearance
	self.EnterModel:SetValue("")
	self.ApplyModel:SetDisabled(true)
	self.EnterSkin:SetValue("")
	self.ApplySkin:SetDisabled(true)
	self.EnterScale:SetValue("")
	self.ApplyScaleTemp:SetDisabled(true)
	self.ApplyScalePerm:SetDisabled(true)

	self.SelectedPlayer = nil
	self.SelectedCharID = nil
end

function PANEL:CreateLabel(text, bold, wide)
	local label = self:Add("DLabel")

	label:SetFont("CombineControl.LabelMedium" .. (bold and "Bold" or ""))
	label:SetWide(wide or 150)
	label:SetText(text)

	return label
end

function PANEL:CreateButton(text, wide, doClick)
	local button = self:Add("DButton")

	button:SetText(text)
	button:SetWide(wide or 150)
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

	entry:SetWide(wide or 150)
	entry:SetTall(22)

	return entry
end

function PANEL:PerformLayout(w, h)
	self.List:AlignLeft()
	self.List:StretchToParent(nil, nil, nil, 0)

	-- Basic Information
	self.InformationLabel:MoveRightOf(self.List, 10)
	self.InformationLabel:AlignTop()

	self.NameLabel:MoveRightOf(self.List, 10)
	self.NameLabel:MoveBelow(self.InformationLabel, 5)

	self.ApplyName:AlignRight()
	self.ApplyName:MoveBelow(self.InformationLabel, 5)

	self.EnterName:MoveRightOf(self.NameLabel, 0)
	self.EnterName:StretchRightTo(self.ApplyName, 5)
	self.EnterName:MoveBelow(self.InformationLabel, 5)

	self.FlagLabel:MoveRightOf(self.List, 10)
	self.FlagLabel:MoveBelow(self.NameLabel, 5)

	self.SelectFlag:MoveRightOf(self.FlagLabel, 0)
	self.SelectFlag:MoveBelow(self.NameLabel, 5)

	self.ApplyFlag:MoveRightOf(self.SelectFlag, 5)
	self.ApplyFlag:MoveBelow(self.NameLabel, 5)

	self.HiddenLabel:MoveRightOf(self.List, 10)
	self.HiddenLabel:MoveBelow(self.FlagLabel, 5)

	self.HiddenToggle:MoveRightOf(self.HiddenLabel)
	self.HiddenToggle:SetY(self.HiddenLabel:GetY() + 3)

	self.AppearanceLabel:MoveRightOf(self.List, 10)
	self.AppearanceLabel:MoveBelow(self.HiddenLabel, 5)

	self.ModelLabel:MoveRightOf(self.List, 10)
	self.ModelLabel:MoveBelow(self.AppearanceLabel, 5)

	self.ApplyModel:AlignRight()
	self.ApplyModel:MoveBelow(self.AppearanceLabel, 5)

	self.EnterModel:MoveRightOf(self.ModelLabel, 0)
	self.EnterModel:StretchRightTo(self.ApplyModel, 5)
	self.EnterModel:MoveBelow(self.AppearanceLabel, 5)

	self.SkinLabel:MoveRightOf(self.List, 10)
	self.SkinLabel:MoveBelow(self.ModelLabel, 5)

	self.EnterSkin:MoveRightOf(self.SkinLabel, 0)
	self.EnterSkin:MoveBelow(self.ModelLabel, 5)

	self.ApplySkin:MoveRightOf(self.EnterSkin, 5)
	self.ApplySkin:MoveBelow(self.ModelLabel, 5)

	self.ScaleLabel:MoveRightOf(self.List, 10)
	self.ScaleLabel:MoveBelow(self.SkinLabel, 5)

	self.EnterScale:MoveRightOf(self.ScaleLabel, 0)
	self.EnterScale:MoveBelow(self.SkinLabel, 5)

	self.ApplyScaleTemp:MoveRightOf(self.EnterScale, 5)
	self.ApplyScaleTemp:MoveBelow(self.SkinLabel, 5)

	self.ApplyScalePerm:MoveRightOf(self.ApplyScaleTemp, 5)
	self.ApplyScalePerm:MoveBelow(self.SkinLabel, 5)
end

derma.DefineControl("CC_AdminMenu_Characters", "", PANEL, "Panel")
