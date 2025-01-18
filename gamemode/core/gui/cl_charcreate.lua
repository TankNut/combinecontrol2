local PANEL = {}

function PANEL:Init()
	self:SetSize(700, 400)
	self:DockPadding(10, 10, 10, 10)

	self:SetCloseOnPause(true)

	self.Left = self:Add("DPanel")
	self.Left:DockMargin(0, 0, 5, 0)
	self.Left:Dock(LEFT)
	self.Left:SetWide(480)
	self.Left:SetPaintBackground(false)

	self.Content = self.Left:Add("DPanel")
	self.Content:Dock(FILL)
	self.Content:SetPaintBackground(false)

	self.Buttons = self.Left:Add("DPanel")
	self.Buttons:DockMargin(0, 5, 0, 0)
	self.Buttons:Dock(BOTTOM)
	self.Buttons:SetTall(22)
	self.Buttons:SetPaintBackground(false)

	self.Next = self.Buttons:Add("DButton")
	self.Next:Dock(RIGHT)
	self.Next:SetWide(50)
	self.Next:SetText("Next")

	self.Next:SetDisabled(true)

	self.Next.DoClick = function(pnl)
		self:GoForward()
	end

	self.Back = self.Buttons:Add("DButton")
	self.Back:DockMargin(0, 0, 0, 0)
	self.Back:Dock(LEFT)
	self.Back:SetWide(50)
	self.Back:SetText("Back")

	self.Back.DoClick = function(pnl)
		self:GoBack()
	end

	self.Progress = self.Buttons:Add("CCProgressBar")
	self.Progress:DockMargin(5, 0, 5, 0)
	self.Progress:Dock(FILL)

	self.Model = self:Add("CC_CharacterModel")
	self.Model:Dock(FILL)
	self.Model:SetAllowManipulation(true)
	self.Model.Zoom = 0.6

	self:MakePopup()
	self:Center()
end

function PANEL:OnClose()
	self:Remove()

	GUI.Open(#lp:GetCharacterTypes() > 1 and "CharacterType" or "CharacterSelect")
end

function PANEL:GoBack()
	if self.Page == 1 then
		self:Close()

		return
	end

	self:SetPage(self.Page - 1)
end

function PANEL:GoForward()
	if self.Page == #self.CharType.Pages then
		self:Submit()

		return
	end

	self:SetPage(self.Page + 1)
end

function PANEL:Submit()
	self.Next:SetDisabled(true)

	netstream.Send("CreateCharacter", self.CharType.ID, self.Options)
end

function PANEL:CheckPage()
	local options = self.CharType.Options
	local rules = {}

	for _, id in ipairs(self:GetCurrentOptions()) do
		rules[id] = self.CharType.Validate[id]
	end

	local ok, field, err = validate.Multi(self.Options, rules)

	if not ok then
		err = string.format("%s: %s", options[field].Name, err)
	end

	self.Next:SetDisabled(not ok)
	self.Next:SetTooltip(err)

	self:UpdateProgress(ok)

	return ok
end

function PANEL:UpdateProgress(ok)
	local page = self.Page
	local max = #self.CharType.Pages

	if page == max then
		self.Next:SetText("Finish")
	else
		self.Next:SetText("Next")
	end

	if not ok then
		page = page - 1
	end

	self.Progress:SetProgress(page / max)
	self.Progress:SetProgressText(string.format("%s%%", page / max * 100))
end

function PANEL:GetCurrentOptions()
	return self.CharType.Pages[self.Page]
end

function PANEL:SetPage(val)
	self.Page = val
	self.Content:Clear()

	for _, id in ipairs(self:GetCurrentOptions()) do
		local option = self.CharType.Options[id]
		local panel = self.Content:Add(option.Panel)

		panel.CharCreate = self
		panel.ID = id

		panel:SetTitle(option.Name)
		panel:Setup(option.Args, self.Options[id], self.Options)
	end

	self:CheckPage()
end

function PANEL:UpdateModel(key)
	self.CharType:SetupModelPanel(self.Model, self.Options, key)
end

function PANEL:SetOption(key, val)
	self.Options[key] = val
	self:CheckPage()

	for _, panel in ipairs(self.Content:GetChildren()) do
		panel:OnOptionChanged(key, val)
	end

	self:UpdateModel(key)
end

function PANEL:PaintFullScreen(x, y, w, h)
	draw.DrawBackgroundBlur(1, x, y, w, h)
end

function PANEL:Setup(charType)
	self:SetTopBar("Character Creation - " .. charType:GetName())

	self.Options = {}

	self.CharType = charType
	self:SetPage(1)
	self:UpdateModel()
end

derma.DefineControl("GUI_CharacterCreate", "", PANEL, "CC_Frame")

GUI.Register("CharacterCreate", function(charType)
	local panel = vgui.Create("GUI_CharacterCreate")

	panel:Setup(charType)

	return panel
end, true)
