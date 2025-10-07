local PANEL = {}

function PANEL:Init()
	self.List = self:Add("DListView")
	self.List:SetMultiSelect(false)
	self.List:AddColumn("Timestamp"):SetFixedWidth(ui.Scale(120))
	self.List:AddColumn("Admin Name"):SetFixedWidth(ui.Scale(120))
	self.List:AddColumn("Banned SteamID"):SetFixedWidth(ui.Scale(150))
	self.List:AddColumn("Length"):SetFixedWidth(ui.Scale(70))
	self.List:AddColumn("Reason")
	self.List.OnRowSelected = function(panel, index, row)
		self.RevokeBan:SetDisabled(false)
	end

	self.Refresh = self:Add("DButton")
	self.Refresh:SetText("Refresh Bans")
	self.Refresh:SetSize(ui.Scale(100), ui.Scale(20))
	self.Refresh.DoClick = function()
		self:RequestBans()
	end

	self.RevokeBan = self:Add("DButton")
	self.RevokeBan:SetText("Revoke Ban")
	self.RevokeBan:SetSize(ui.Scale(100), ui.Scale(20))
	self.RevokeBan:SetDisabled(true)
	self.RevokeBan.DoClick = function()
		self:DoRevokeBan()
	end

	self:RequestBans()
end

function PANEL:RequestBans()
	self.List:Clear()

	self.Refresh:SetDisabled(true)
	self.RevokeBan:SetDisabled(true)

	async.Start(function()
		local bans = request.Send("RequestBans")

		if not IsValid(self) then
			return
		end

		self.Refresh:SetDisabled(false)

		for _, ban in SortedPairsByMemberValue(bans, "Timestamp") do
			local bannedOn = os.date("%Y-%m-%d %H:%M:%S", ban.Timestamp)
			local bannedFor = ban.Length > 0 and string.NiceTime(ban.Length) or "Permanent"
			local banRemaining =  ban.Length > 0 and string.NiceTime(ban.Timestamp + ban.Length - os.time()) or "Permanent"

			local line = self.List:AddLine(
				bannedOn,
				ban.Admin,
				ban.SteamID,
				bannedFor,
				ban.Reason
			)

			line.Data = ban
			line:SetTooltipPanelOverride("CC_Tooltip")
			line:SetTooltip(string.format([[<b>Banned SteamID:</b> <dark>%s</dark>
<b>Banned By:</b> <dark>%s</dark>
<b>Banned On:</b> <dark>%s</dark>
<b>Time For:</b> <dark>%s</dark>
<b>Time Left:</b> <dark>%s</dark>

<dark>%s
]], ban.SteamID, ban.Admin, bannedOn, bannedFor, banRemaining, ban.Reason))
		end
	end)
end

function PANEL:DoRevokeBan()
	local _, line = self.List:GetSelectedLine()
	local steamID = line.Data.SteamID

	async.Start(function()
		local confirm = ui.Open("Input", "confirm", "Revoke Ban", {
			Prompt = string.format("Revoke %s's ban and allow them back onto the server?", steamID),
		})

		if not confirm then
			return
		end

		RunConsoleCommand("rpa_unban", steamID)

		if IsValid(self) then
			self.RevokeBan:SetDisabled(true)

			if IsValid(line) then
				self.List:RemoveLine(line:GetID())
			end
		end
	end)
end

function PANEL:PerformLayout(w, h)
	self.List:StretchToParent(0, 0, 0, ui.Scale(28))

	self.Refresh:AlignLeft()
	self.Refresh:AlignBottom()

	self.RevokeBan:AlignRight()
	self.RevokeBan:AlignBottom()
end

vgui.Register("CC_AdminMenu_Bans", PANEL, "Panel")
