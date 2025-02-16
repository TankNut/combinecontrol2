DEFINE_BASECLASS("CC_Frame")

local PANEL = {}

function PANEL:Init()
	self:SetSize(700, 400)
	self:DockPadding(10, 10, 10, 10)

	self:SetCloseOnPause(true)

	self.Left = self:Add("Panel")
	self.Left:DockMargin(0, 0, 5, 0)
	self.Left:Dock(LEFT)
	self.Left:SetWide(480)

	self.Content = self.Left:Add("Panel")
	self.Content:Dock(FILL)

	self.Buttons = self.Left:Add("Panel")
	self.Buttons:DockMargin(0, 5, 0, 0)
	self.Buttons:Dock(BOTTOM)
	self.Buttons:SetTall(22)

	self.Next = self.Buttons:Add("DButton")
	self.Next:Dock(RIGHT)
	self.Next:SetWide(50)

	self.Next:SetDisabled(true)

	self.Next.DoClick = function(pnl)
		self:GoForward()
	end

	self.Back = self.Buttons:Add("DButton")
	self.Back:DockMargin(0, 0, 0, 0)
	self.Back:Dock(LEFT)
	self.Back:SetWide(50)

	self.Back.DoClick = function(pnl)
		self:GoBack()
	end

	self.Model = self:Add("CC_CharacterModel")
	self.Model:Dock(FILL)
	self.Model:SetAllowManipulation(true)
	self.Model:SetBaseYaw(-20)

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

	netstream.Send("CreateCharacter", self.CharType.ClassName, self.Options)
end

function PANEL:CheckPage()
	local options = self.CharType.Options
	local rules = {}

	for _, id in ipairs(self:GetPageData().Options) do
		rules[id] = self.CharType.Validate[id]
	end

	local ok, field, err = validate.Multi(self.Options, rules)

	if not ok then
		err = string.format("%s: %s", options[field].Name, err)
	end

	self.Next:SetDisabled(not ok)
	self.Next:SetTooltip(err)

	return ok
end

function PANEL:GetPageData(index)
	return self.CharType.Pages[index or self.Page]
end

function PANEL:PageCount()
	return #self.CharType.Pages
end

function PANEL:SetPage(index)
	self.Page = index
	self.Content:Clear()

	local data = self:GetPageData()

	for _, id in ipairs(data.Options) do
		local option = self.CharType.Options[id]
		local panel = self.Content:Add(option.Panel)

		panel.CharCreate = self
		panel.ID = id

		panel:SetTitle(option.Name)
		panel:SetTooltip(option.Description or "")
		panel:PerformSetup(option.Args, self.Options[id], self.Options)
	end

	self.Back:SetText(index == 1 and "Cancel" or "Back: " .. self:GetPageData(index - 1).Name)
	self.Next:SetText(index == self:PageCount() and "Finish" or "Next: " .. self:GetPageData(index + 1).Name)

	self:InvalidateLayout()

	self:CheckPage()
end

function PANEL:PerformLayout(w, h)
	BaseClass.PerformLayout(self, w, h)

	self.Back:SizeToContentsX(25)
	self.Next:SizeToContentsX(25)
end

function PANEL:UpdateModel(key)
	local appearance = self.CharType:GetAppearance(self.Options, key)

	if appearance then
		self.Model:SetAppearance(appearance)
	end
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
