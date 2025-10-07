local PANEL = {}

function PANEL:Init()
	local padding = ui.Scale(10)

	self:SetWide(ui.Scale(200))
	self:DockPadding(padding, padding, padding, padding)

	if lp:HasCharacter() then
		self:SetToggleKey("gm_showteam")
		self:SetCloseOnPause()
	end

	self:SetTopBar("Character Selection")
	self:Populate()

	self:MakePopup()
	self:Center()
end

function PANEL:Populate()
	self.Buttons = {}

	local characters = {}
	local temp = {}

	for id, data in pairs(lp:CharacterList()) do
		if data.Event then
			temp[id] = data.Name
		else
			characters[id] = data.Name
		end
	end

	local margin = ui.Scale(5)
	local w, h = ui.Scale(64), ui.Scale(22)

	for id, name in SortedPairs(characters) do
		local button = self:Add("DButton")

		button:SetSize(w, h)
		button:DockMargin(0, 0, 0, margin)
		button:Dock(TOP)
		button:SetText(name)

		button.DoClick = function(pnl)
			if self.DeleteMode then
				netstream.Send("DeleteCharacter", id)
			else
				netstream.Send("SelectCharacter", id)

				button:SetDisabled(true)
			end
		end

		if id == lp:CharID() then
			button:SetDisabled(true)
		end

		button.ID = id

		table.insert(self.Buttons, button)
	end

	local numCharacters = #self.Buttons
	local max = Config.Get("MaxCharacters")

	if numCharacters < max then
		local button = self:Add("DButton")

		button:SetSize(w, h)
		button:DockMargin(0, 0, 0, margin)
		button:Dock(TOP)
		button:SetText("Empty slot")
		button:SetDisabled(true)
	end

	for id, name in SortedPairs(temp) do
		local button = self:Add("DButton")

		button:SetSize(w, h)
		button:DockMargin(0, 0, 0, margin)
		button:Dock(TOP)
		button:SetText("[" .. name .. "]")

		button.DoClick = function(pnl)
			if self.DeleteMode then
				netstream.Send("DeleteCharacter", id)
			else
				netstream.Send("SelectCharacter", id)

				button:SetDisabled(true)
			end
		end

		if id == lp:CharID() then
			button:SetDisabled(true)
		end

		button.ID = id

		table.insert(self.Buttons, button)
	end

	self.CreateNew = self:Add("DButton")
	self.CreateNew:SetSize(w, h)
	self.CreateNew:DockMargin(0, ui.Scale(15), 0, 0)
	self.CreateNew:Dock(TOP)
	self.CreateNew:SetText("Create character")

	self.CreateNew.DoClick = function(pnl)
		self:Remove()
		ui.Open("CharacterType")
	end

	if numCharacters >= max then
		self.CreateNew:SetDisabled(true)
	end

	if #lp:GetCharacterGenerators() > 0 then
		self.GenCharacter = self:Add("DButton")
		self.GenCharacter:SetSize(w, h)
		self.GenCharacter:DockMargin(0, margin, 0, 0)
		self.GenCharacter:Dock(TOP)
		self.GenCharacter:SetText("Create event character")

		self.GenCharacter.DoClick = function(pnl)
			self:Remove()
			ui.Open("CharacterGen")
		end
	end

	self.Delete = self:Add("DButton")
	self.Delete:SetSize(w, h)
	self.Delete:DockMargin(0, margin, 0, 0)
	self.Delete:Dock(TOP)
	self.Delete:SetText("Delete")

	self.Delete.DoClick = function(pnl)
		self.DeleteMode = not self.DeleteMode

		pnl:SetTextColor(self.DeleteMode and Color("cc_primary") or nil)

		if self.DeleteMode then
			for _, v in pairs(self.Buttons) do
				v:SetDisabled(false)
			end
		else
			local id = lp:CharID()

			for _, v in pairs(self.Buttons) do
				v:SetDisabled(v.ID == id)
			end
		end
	end

	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)
end

function PANEL:PaintFullScreen(x, y, w, h)
	draw.DrawBackgroundBlur(1, x, y, w, h)
end

vgui.Register("GUI_CharacterSelect", PANEL, "CC_Frame")

ui.Register("CharacterSelect", function()
	return vgui.Create("GUI_CharacterSelect")
end, true)
