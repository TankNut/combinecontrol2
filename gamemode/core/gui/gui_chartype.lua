local PANEL = {}

function PANEL:Init()
	local padding = ui.Scale(10)

	self:SetWide(ui.Scale(200))
	self:DockPadding(padding, padding, padding, padding)

	if lp:HasCharacter() then
		self:SetCloseOnPause()
	end

	self:SetTopBar("Character Type")
	self:Populate()

	self:MakePopup()
	self:Center()
end

function PANEL:Populate()
	local margin = ui.Scale(5)
	local w, h = ui.Scale(64), ui.Scale(22)

	for _, id in ipairs(lp:GetCharacterTypes()) do
		local charType = CharacterCreate.Get(id)
		local button = self:Add("DButton")

		button:SetSize(w, h)
		button:DockMargin(0, 0, 0, margin)
		button:Dock(TOP)
		button:SetText(charType:GetName())

		button.DoClick = function(pnl)
			self:Remove()
			ui.Open("CharacterCreate", charType)
		end
	end

	self.Cancel = self:Add("DButton")
	self.Cancel:SetSize(w, h)
	self.Cancel:DockMargin(0, ui.Scale(15), 0, 0)
	self.Cancel:Dock(TOP)
	self.Cancel:SetText("Cancel")

	self.Cancel.DoClick = function(pnl)
		self:Close()
	end

	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)
end

function PANEL:OnClose()
	self:Remove()
	ui.Open("CharacterSelect")
end

function PANEL:PaintFullScreen(x, y, w, h)
	draw.DrawBackgroundBlur(1, x, y, w, h)
end

vgui.Register("GUI_CharacterType", PANEL, "CC_Frame")

ui.Register("CharacterType", function()
	if #lp:GetCharacterTypes() == 1 then
		local charType = CharacterCreate.Get(lp:GetCharacterTypes()[1])

		ui.Open("CharacterCreate", charType)

		return
	end

	return vgui.Create("GUI_CharacterType")
end, true)
