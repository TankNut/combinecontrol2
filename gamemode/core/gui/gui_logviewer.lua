local PANEL = {}

function PANEL:Init()
	local padding = ui.Scale(10)

	self:SetSize(ui.Scale(800), ui.Scale(500))
	self:DockPadding(padding, padding, padding, padding)

	self:SetDraggable(true)
	self:SetCloseOnPause()

	self:SetTopBar("Log Viewer")

	self:MakePopup()
	self:Center()

	self.Bottom = self:Add("Panel")
	self.Bottom:DockMargin(0, padding, 0, 0)
	self.Bottom:Dock(BOTTOM)
	self.Bottom:SetTall(22)

	self.Logs = self:Add("DListView")
	self.Logs:DockMargin(0, 0, padding, 0)
	self.Logs:Dock(LEFT)
	self.Logs:SetWide(ui.Scale(560))
	self.Logs:AddColumn("Timestamp"):SetFixedWidth(ui.Scale(120))
	self.Logs:AddColumn("Log")
	self.Logs:AddColumn("Type"):SetFixedWidth(ui.Scale(100))

	self.Logs.DoDoubleClick = function(_, _, line)
		self:PrintToConsole(line)
	end

	self.Logs.OnRowSelected = function(_, _, line)
		self:UpdateDataViewer(line)
	end

	self.Logs.OnRowRightClick = function(_, _, line)
		local dmenu = DermaMenu(false, line)

		dmenu:SetPos(gui.MousePos())
		dmenu.Think = function()
			if not IsValid(line) then
				dmenu:Remove()
			end
		end

		dmenu:AddOption("Copy to clipboard", function()
			SetClipboardText(self:GetLogText(line))
		end)

		dmenu:AddOption("Dump data to console", function() self:DumpKeyValues(line) end)
		dmenu:Open()
	end

	self.Data = self:Add("DListView")
	self.Data:Dock(FILL)
	self.Data:AddColumn("Key"):SetFixedWidth(80)
	self.Data:AddColumn("Value")

	self.Data.OnRowRightClick = function(_, _, line)
		local dmenu = DermaMenu(false, line)

		dmenu:SetPos(gui.MousePos())
		dmenu.Think = function()
			if not IsValid(line) then
				dmenu:Remove()
			end
		end

		dmenu:AddOption("Copy Key", function()
			SetClipboardText(line:GetValue(1))
		end)

		dmenu:AddOption("Copy Value", function()
			SetClipboardText(line:GetValue(2))
		end)

		dmenu:Open()
	end

	self.Previous = self.Bottom:Add("DButton")
	self.Previous:Dock(LEFT)
	self.Previous:SetWide(ui.Scale(150))
	self.Previous:SetText("Previous Page")
	self.Previous:SetDisabled(true)
	self.Previous:SetZPos(1)

	self.Previous.DoClick = function()
		self.Offset = self.Offset - Config.Get("LogLines")
		self:SendRequest()
	end

	local margin = ui.Scale(5)

	self.Entry = self.Bottom:Add("DTextEntry")
	self.Entry:DockMargin(margin, 0, margin, 0)
	self.Entry:Dock(LEFT)
	self.Entry:SetText("0")
	self.Entry:SetZPos(2)
	self.Entry:SetDisabled(true)

	self.Entry.OnEnter = function(_, str)
		self.Offset = tonumber(str) or 0

		self:SendRequest()
	end

	self.Refresh = self.Bottom:Add("DButton")
	self.Refresh:DockMargin(0, 0, margin, 0)
	self.Refresh:Dock(LEFT)
	self.Refresh:SetWide(100)
	self.Refresh:SetText("Refresh")
	self.Refresh:SetDisabled(true)
	self.Refresh:SetZPos(3)

	self.Refresh.DoClick = function()
		self:SendRequest()
	end

	self.Next = self.Bottom:Add("DButton")
	self.Next:Dock(LEFT)
	self.Next:SetWide(150)
	self.Next:SetText("Next Page")
	self.Next:SetDisabled(true)
	self.Next:SetZPos(4)

	self.Next.DoClick = function()
		self.Offset = self.Offset + Config.Get("LogLines")
		self:SendRequest()
	end
end

function PANEL:GetLogText(line)
	return string.format("[%s] [%s] - %s", line:GetValue(1), line:GetValue(3), line:GetValue(2))
end

function PANEL:PrintToConsole(line)
	print(self:GetLogText(line))
end

function PANEL:DumpKeyValues(line)
	local lines = {}

	for _, pair in ipairs(sfs.decode(line.KeyValues)) do
		table.insert(lines, string.format("  %s: %s", pair[1], pair[2]))
	end

	print(string.format([[%s
%s]], self:GetLogText(line), table.concat(lines, "\n")))
end

function PANEL:UpdateDataViewer(line)
	self.Data:Clear()

	for _, pair in ipairs(sfs.decode(line.KeyValues)) do
		self.Data:AddLine(pair[1], pair[2])
	end
end

function PANEL:SendRequest()
	self.Offset = math.max(self.Offset, 0)

	self.Entry:SetText(self.Offset)

	self.Previous:SetDisabled(true)
	self.Entry:SetDisabled(true)
	self.Refresh:SetDisabled(true)
	self.Next:SetDisabled(true)

	async.Start(function()
		local logs = request.Send("GetLogs", {
			Name = self.Config.Name,
			Data = self.Config.Data,
			Offset = self.Offset,
			From = self.Config.From,
			To = self.Config.To
		})

		if not IsValid(self) then
			return
		end

		self.Refresh:SetDisabled(false)
		self.Entry:SetDisabled(false)

		if self.Offset > 0 then
			self.Previous:SetDisabled(false)
		end

		self.Logs:Clear()

		if #logs == 0 then
			self.Logs:AddLine("No logs found")

			return
		end

		for _, log in ipairs(logs) do
			local line = self.Logs:AddLine(os.date("%Y-%m-%d %H:%M:%S", log.Timestamp), log.Log, log.Name)

			line.KeyValues = log.Data
			line.Timestamp = log.Timestamp
			line.Columns[2]:SetContentAlignment(7)
			line.Columns[2]:SetTextInset(5, 2)

			line:SetTooltipPanelOverride("CC_Tooltip")
			line:SetTooltip(string.format([[<b>Log:</b> <dark>%s</dark>
<b>Type:</b> <dark>%s</dark>
<dark>%s ago
]], string.Escape(log.Log), log.Name, string.NiceTime(os.time() - log.Timestamp)))
		end

		if #logs == Config.Get("LogLines") then
			self.Next:SetDisabled(false)
		end

		self.Logs:SortByColumn(1, true)
	end)
end

function PANEL:Setup(config)
	self.Config = config
	self.Offset = 0

	self:SendRequest()
end

vgui.Register("GUI_LogViewer", PANEL, "CC_Frame")

ui.Register("LogViewer", function(config)
	local panel = vgui.Create("GUI_LogViewer")

	panel:Setup(config)

	return panel
end)
