local PANEL = {}

function PANEL:Init()
	self:SetCookieName("cc_" .. Config.Get("InternalName") .. "_logs")

	self.NameLabel = self:Add("ScribeLabel")
	self.NameLabel:SetText([[<b>Log Types</b>
<dark>  Supports both partial and full matches, use autocomplete or check on the right to see what types are available]])

	self.NameFilter = self:Add("DTextEntry")
	self.NameFilter:SetPlaceholderText("All logs")
	self.NameFilter:SetUpdateOnType(true)
	self.NameFilter:SetText(self:GetCookie("NameFilter", ""))

	self.NameFilter.OnValueChange = function(_, str)
		self:SetCookie("NameFilter", str)
	end

	self.NameFilter.GetAutoComplete = function(_, str)
		local names = {}

		for _, name in SortedPairsByValue(table.GetKeys(Log.Types)) do
			if string.find(name, "^" .. str) then
				table.insert(names, name)
			end
		end

		return names
	end

	self.NameFilter.OnChange = function(pnl)
		if IsValid(pnl.Menu) then
			pnl.Menu:SetSkin("CombineControlNew")
		end
	end

	self.KeyValues = self:Add("DListView")
	self.KeyValues:SetMultiSelect(false)
	self.KeyValues:AddColumn("Key"):SetFixedWidth(120)
	self.KeyValues:AddColumn("Value")

	self.KeyValues.DoDoubleClick = function(_, id)
		self.KeyValues:RemoveLine(id)
		self:SaveKeyValues()
	end

	self:LoadKeyValues()

	self.TimeLabel = self:Add("ScribeLabel")
	self.TimeLabel:SetText([[<b>Time Range</b>
<dark>  All times are in UTC, you can either use precise timestamps or relative ones (e.g. -2 weeks)]])

	self.Time = self:Add("DTextEntry")
	self.Time:SetPlaceholderText("Now")
	self.Time:SetUpdateOnType(true)
	self.Time:SetText(self:GetCookie("Time", ""))

	self.Time.OnValueChange = function(_, str)
		self:SetCookie("Time", str)
	end

	self.FillTime = self:Add("DButton")
	self.FillTime:SetText("Auto-Fill")

	self.FillTime.DoClick = function()
		local str = os.date("%Y-%m-%d %H:%M:%S")

		self.Time:SetText(str)
		self:SetCookie("Time", str)
	end

	self.Length = self:Add("DTextEntry")
	self.Length:SetPlaceholderText("Anytime")
	self.Length:SetUpdateOnType(true)
	self.Length:SetText(self:GetCookie("Length", ""))

	self.Length.OnValueChange = function(_, str)
		self:SetCookie("Length", str)
	end

	self.FillLength = self:Add("DButton")
	self.FillLength:SetText("Auto-Fill")

	self.FillLength.DoClick = function()
		local str = os.date("%Y-%m-%d %H:%M:%S")

		self.Length:SetText(str)
		self:SetCookie("Length", str)
	end

	self.KeyInput = self:Add("DTextEntry")
	self.KeyInput:SetPlaceholderText("Key")
	self.KeyInput:SetUpdateOnType(true)
	self.KeyInput:SetText(self:GetCookie("KeyInput", ""))

	self.KeyInput.OnValueChange = function(_, str)
		self:SetCookie("KeyInput", str)
	end

	self.ValueInput = self:Add("DTextEntry")
	self.ValueInput:SetPlaceholderText("Value")

	self.ValueInput.OnEnter = function(_, str)
		local key = self.KeyInput:GetValue()

		if #key > 0 and #str > 0 then
			self.KeyValues:AddLine(key, str)
			self.ValueInput:SetText("")
			self.ValueInput:RequestFocus()

			self:SaveKeyValues()
		end
	end

	self.Search = self:Add("DButton")
	self.Search:SetText("Search Logs")
	self.Search:SizeToContentsX(20)

	self.Search.DoClick = function()
		self:StartSearch()
	end

	self.Clear = self:Add("DButton")
	self.Clear:SetText("Clear")

	self.Clear.DoClick = function()
		self.NameFilter:SetValue("")
		self.Time:SetValue("")
		self.Length:SetValue("")
		self.KeyInput:SetValue("")

		self.KeyValues:Clear()
		self:DeleteCookie("KeyValues")
	end

	local lookup = {}
	local prefixes = {}

	for _, name in ipairs(table.GetKeys(Log.Types)) do
		local prefix = string.match(name, "^([%a]+_)")

		if prefix and not lookup[prefix] then
			table.insert(prefixes, prefix)
			lookup[prefix] = true
		end
	end

	self.ExtraHelp = self:Add("ScribeLabel")
	self.ExtraHelp:SetText(string.format([[<b>Logs</b>
<dark>  If you just want to view the latest logs in chronological format, hit 'Clear' (if needed) and 'Search Logs' and it'll do just that. Otherwise you can use the various options on this page to narrow down your search to specific log types, a specific date/time range or even specific key-value sets

Most logs will have some amount of key-value data attached to it that you can filter by, filters on the same key work as OR, filters between different keys work as AND

Any data entered here will be saved between sessions

</dark><b>Log prefixes:</b><dark>
%s]], table.concat(prefixes, "    ")))
end

function PANEL:GetTime(str, length)
	local year, month, day, hour, min, sec = string.match(str, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")

	local ok, timestamp = pcall(os.time, {
		year = year,
		month = month,
		day = day,
		hour = hour,
		min = min,
		sec = sec
	})

	if ok then
		return false, timestamp
	end

	local negative = str[1] == "-"

	if negative then
		str = string.sub(str, 2)
	end

	local duration = util.Duration(str)

	if duration then
		return true, negative and -duration or duration
	end
end

function PANEL:StartSearch()
	local data = {}

	for _, line in pairs(self.KeyValues:GetLines()) do
		local key = line:GetValue(1)
		local value = line:GetValue(2)

		if not data[key] then
			data[key] = {value}
		else
			table.insert(data[key], value)
		end
	end

	local name = self.NameFilter:GetValue()
	local isRelative, time = self:GetTime(self.Time:GetValue())
	local isLength, length = self:GetTime(self.Length:GetValue())

	if isRelative then
		time = os.time() + time
	elseif not time then
		time = os.time()
	end

	local from, to

	if length then
		if isLength then
			from = math.min(time, time + length)
			to = math.max(time, time + length)
		else
			from = math.min(time, length)
			to = math.max(time, length)
		end
	else
		to = time
	end

	GUI.Open("LogViewer", {
		Name = #name > 0 and name or nil,
		Data = data,
		From = from,
		To = to
	})
end

function PANEL:LoadKeyValues()
	self.KeyValues:Clear()

	local data = self:GetCookie("KeyValues", {})

	if isstring(data) then
		data = util.JSONToTable(data)
	end

	for _, columns in pairs(data) do
		self.KeyValues:AddLine(unpack(columns))
	end
end

function PANEL:SaveKeyValues()
	local data = {}

	for k, line in pairs(self.KeyValues:GetLines()) do
		data[k] = {line:GetValue(1), line:GetValue(2)}
	end

	self:SetCookie("KeyValues", util.TableToJSON(data))
end

function PANEL:PerformLayout(w, h)
	self.NameLabel:SetWide(200)
	self.NameLabel:SizeToContentsY()

	self.NameFilter:MoveBelow(self.NameLabel, 5)
	self.NameFilter:SetWide(200)

	self.KeyInput:SetWide(115)
	self.KeyInput:SetX(self.KeyValues:GetX())
	self.KeyInput:AlignBottom()

	self.ValueInput:SetWide(self.KeyValues:GetWide() - 120)
	self.ValueInput:MoveRightOf(self.KeyInput, 5)
	self.ValueInput:AlignBottom()

	self.KeyValues:MoveRightOf(self.NameFilter, 10)
	self.KeyValues:SetWide(300)
	self.KeyValues:StretchBottomTo(self.KeyInput, 5)

	self.TimeLabel:SetWide(200)
	self.TimeLabel:SizeToContentsY()
	self.TimeLabel:MoveBelow(self.NameFilter, 20)

	self.Time:SetWide(135)
	self.Time:MoveBelow(self.TimeLabel, 5)

	self.FillTime:SetSize(60, 20)
	self.FillTime:SetY(self.Time:GetY())
	self.FillTime:MoveRightOf(self.Time, 5)

	self.Length:SetWide(135)
	self.Length:MoveBelow(self.Time, 5)

	self.FillLength:SetSize(60, 20)
	self.FillLength:SetY(self.Length:GetY())
	self.FillLength:MoveRightOf(self.Length, 5)

	self.Search:SetSize(160, 20)
	self.Search:AlignBottom()

	self.Clear:SetTall(20)
	self.Clear:SetY(self.Search:GetY())
	self.Clear:MoveRightOf(self.Search, 5)
	self.Clear:StretchRightTo(self.KeyValues, 10)

	self.ExtraHelp:MoveRightOf(self.KeyValues, 10)
	self.ExtraHelp:StretchToParent(nil, 0, 0, 0)
end

derma.DefineControl("CC_AdminMenu_Logs", "", PANEL, "Panel")
