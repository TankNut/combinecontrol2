local PANEL = {}

function PANEL:Init()
	self.List = self:Add("DListView")
	self.List:SetMultiSelect(false)
	self.List:AddColumn("Usergroup"):SetFixedWidth(70)
	self.List:AddColumn("SteamID"):SetFixedWidth(150)
	self.List:AddColumn("Alias")
	self.List:AddColumn("Steam Name")
	self.List:AddColumn("Last Seen"):SetFixedWidth(100)

	self.Refresh = self:Add("DButton")
	self.Refresh:SetText("Refresh Roster")
	self.Refresh:SetWide(100)
	self.Refresh.DoClick = function()
		self:RequestAdminRoster()
	end

	if lp:IsSuperAdmin() then
		self.List.OnRowSelected = function(panel, index, row)
			local group = row.Data.UserGroup

			self.UpdateAlias:SetDisabled(not lp:CanTargetUserGroup(group))
			self.DemoteUser:SetDisabled(IsElevatedUserGroup(group))
		end

		self.AddUser = self:Add("DButton")
		self.AddUser:SetText("Add User")
		self.AddUser:SetWide(100)
		self.AddUser.DoClick = function()
			self:DoAddUser()
		end

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
	end

	self:RequestAdminRoster()
end

function PANEL:RequestAdminRoster()
	self.Refresh:SetDisabled(true)

	if lp:IsSuperAdmin() then
		self.UpdateAlias:SetDisabled(true)
		self.DemoteUser:SetDisabled(true)
	end

	self.List:Clear()

	async.Start(function()
		local admins = request.Send("AdminRoster")

		if not IsValid(self) then
			return
		end

		self.Refresh:SetDisabled(false)

		for index, admin in pairs(admins) do
			local lastSeen = IsValid(player.GetBySteamID(admin.SteamID)) and "Online" or
				(admin.LastSeen and string.NiceTime(os.time() - admin.LastSeen) .. " ago" or "Never")

			self.List:AddLine(
				string.FirstToUpper(admin.UserGroup),
				admin.SteamID,
				admin.Alias,
				admin.LastNick,
				lastSeen
			).Data = admin
		end

		self.List:SortByColumn(1, false)
	end)
end

local function getName(data)
	return data.Alias or data.LastNick or data.SteamID
end

function PANEL:DoAddUser()
	local existing = table.Lookup(table.Map(self.List:GetLines(), function(line)
		return line.Data.SteamID
	end))

	async.Start(function()
		local steamid = GUI.Open("Input", "string", "Add Admin", {
			Validate = {
				validate.Callback(function(val)
					return util.IsValidSteamID(val), "is not a valid SteamID"
				end),
				validate.Callback(function(val)
					return tobool(not existing[val]), "is already an admin"
				end)
			},
			Name = "That"
		})

		RunConsoleCommand("rpa_setusergroup", steamid, "admin")
	end)
end

function PANEL:DoDemoteUser()
	local _, line = self.List:GetSelectedLine()
	local data = line.Data
	local admin = getName(data)

	async.Start(function()
		local confirm = GUI.Open("Input", "confirm", "Demote Admin to User", {
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
	local steamID = line.Data.SteamID
	local name = getName(line.Data)

	async.Start(function()
		local alias = GUI.Open("Input", "string", "Update Alias for " .. name, {
			Default = line:GetValue(3) or line:GetValue(4),
			Validate = {
				validate.Max(32),
			}
		})

		RunConsoleCommand("rpa_setuseralias", steamID, alias)

		if IsValid(self) and IsValid(line) then
			line.Data.Alias = alias
			line:SetColumnText(3, alias)
		end
	end)
end

function PANEL:PerformLayout(w, h)
	self.List:StretchToParent(0, 0, 0, 30)

	self.Refresh:AlignLeft()
	self.Refresh:AlignBottom()

	if lp:IsSuperAdmin() then
		self.DemoteUser:AlignRight()
		self.DemoteUser:AlignBottom()

		self.UpdateAlias:MoveLeftOf(self.DemoteUser, 5)
		self.UpdateAlias:AlignBottom()

		self.AddUser:MoveLeftOf(self.UpdateAlias, 5)
		self.AddUser:AlignBottom()
	end
end

derma.DefineControl("CC_AdminMenu_Roster", "", PANEL, "Panel")
