local PANEL = {}

function PANEL:CreateLabel(text, wide)
	local label = self:Add("DLabel")

	label:SetFont("CombineControl.LabelMedium")
	label:SetWide(wide or 190)
	label:SetText(text)

	return label
end

function PANEL:Init()
	self.UpdateAlias = self:Add("DButton")
	self.UpdateAlias:SetText("Update Alias")
	self.UpdateAlias:SetWide(100)
	self.UpdateAlias:SetDisabled(true)
	self.UpdateAlias.DoClick = function()
		self:DoUpdateAlias()
	end

	self.DemoteUser = self:Add("DButton")
	self.DemoteUser:SetText("Demote User")
	self.DemoteUser:SetWide(100)
	self.DemoteUser:SetDisabled(true)
	self.DemoteUser.DoClick = function()
		self:DoDemoteUser()
	end

	self.Refresh = self:Add("DButton")
	self.Refresh:SetText("Refresh Roster")
	self.Refresh:SetWide(100)
	self.Refresh.DoClick = function()
		self:RequestAdminRoster()
	end

	self.List = self:Add("DListView")
	self.List:SetMultiSelect(false)
	self.List:AddColumn("Usergroup"):SetFixedWidth(100)
	self.List:AddColumn("SteamID"):SetFixedWidth(150)
	self.List:AddColumn("Alias")
	self.List:AddColumn("Steam Name")
	self.List:AddColumn("Last Seen")

	self.List.OnRowSelected = function(panel, index, row)
		local canTarget = lp:CanTargetUserGroup(row.Data.UserGroup, true)

		self.UpdateAlias:SetDisabled(not canTarget)
		self.DemoteUser:SetDisabled(not canTarget)
	end

	self:RequestAdminRoster()
end

function PANEL:RequestAdminRoster()
	self.UpdateAlias:SetDisabled(true)
	self.DemoteUser:SetDisabled(true)
	self.List:Clear()

	async.Start(function()
		local admins = request.Send("AdminRoster")

		if not IsValid(self) then
			return
		end

		for index, admin in pairs(admins) do
			self.List:AddLine(
				string.FirstToUpper(admin.UserGroup),
				admin.SteamID,
				admin.Alias,
				admin.LastNick,
				admin.LastSeen and string.NiceTime(os.time() - admin.LastSeen) .. " ago" or "Never"
			).Data = admin
		end

		self.List:SortByColumn(1, false)
	end)
end

function PANEL:DoDemoteUser()
	local _, line = self.List:GetSelectedLine()
	local data = line.Data
	local admin = data.SteamID

	if data.Alias then
		admin = data.Alias
	elseif data.LastSeen then
		admin = data.LastSeen
	end

	async.Start(function()
		local confirm = GUI.Open("Input", "confirm", string.format("Demote %s", admin), {
			Prompt = string.format("Demote %s and revoke all of their current in-game access?", admin),
		})

		if not confirm then
			return
		end

		RunConsoleCommand("rpa_setusergroup", data.SteamID, "user")

		if IsValid(self) and IsValid(line) then
			self.List:RemoveLine(line:GetID())
		end
	end)
end

function PANEL:DoUpdateAlias()
	local _, line = self.List:GetSelectedLine()
	local steamId = line.Data.SteamID

	async.Start(function()
		local alias = GUI.Open("Input", "string", "Update Alias", {
			Default = line:GetValue(3),
			Validate = {
				validate.Min(1),
				validate.Max(32),
			}
		})

		RunConsoleCommand("rpa_setuseralias", steamId, alias)

		if IsValid(self) and IsValid(line) then
			line:SetColumnText(3, alias)
		end
	end)
end

function PANEL:PerformLayout(w, h)
	self.Refresh:AlignRight()
	self.Refresh:AlignBottom()

	self.UpdateAlias:AlignLeft()
	self.UpdateAlias:AlignBottom()

	self.DemoteUser:MoveRightOf(self.UpdateAlias, 5)
	self.DemoteUser:AlignBottom()

	self.List:MoveAbove(self.UpdateAlias, 10)
	self.List:StretchToParent(nil, 0, 0, 30)
end

derma.DefineControl("CC_AdminMenu_Roster", "", PANEL, "Panel")
