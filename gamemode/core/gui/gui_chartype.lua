local PANEL = {}

function PANEL:Init()
	self:SetWide(200)
	self:DockPadding(10, 10, 10, 10)

	if lp:HasCharacter() then
		self:SetCloseOnPause(true)
	end

	self:SetTopBar("Character Type")
	self:Populate()

	self:MakePopup()
	self:Center()
end

function PANEL:Populate()
	for _, id in ipairs(lp:GetCharacterTypes()) do
		local charType = CharacterCreate.Get(id)
		local button = self:Add("DButton")

		button:DockMargin(0, 0, 0, 5)
		button:Dock(TOP)
		button:SetText(charType:GetName())

		button.DoClick = function(pnl)
			self:Remove()
			GUI.Open("CharacterCreate", charType)
		end
	end

	self.Cancel = self:Add("DButton")
	self.Cancel:DockMargin(0, 15, 0, 0)
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
	GUI.Open("CharacterSelect")
end

derma.DefineControl("GUI_CharacterType", "", PANEL, "CC_Frame")

GUI.Register("CharacterType", function()
	if #lp:GetCharacterTypes() == 1 then
		local charType = CharacterCreate.Get(lp:GetCharacterTypes()[1])

		GUI.Open("CharacterCreate", charType)

		return
	end

	return vgui.Create("GUI_CharacterType")
end, true)
