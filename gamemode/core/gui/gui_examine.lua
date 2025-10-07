local PANEL = {}

function PANEL:Init()
	local padding = ui.Scale(10)

	self:SetSize(ui.Scale(800), ui.Scale(500))
	self:DockPadding(padding, padding, padding, padding)

	self:SetCloseOnPause()
	self:SetDraggable(true)

	self.Preview = self:Add("CC_CharacterModel")
	self.Preview:DockMargin(0, 0, ui.Scale(20), 0)
	self.Preview:Dock(LEFT)
	self.Preview:SetWide(ui.Scale(200))
	self.Preview:SetBaseYaw(20)
	self.Preview:SetAllowManipulation(true)

	self.CharacterName = self:Add("DLabel")
	self.CharacterName:DockMargin(0, 0, 0, ui.Scale(5))
	self.CharacterName:Dock(TOP)
	self.CharacterName:SetTall(ui.Scale(22))
	self.CharacterName:SetFont("CombineControl.LabelGiant")

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:Dock(FILL)
	self.Scroll:InvalidateParent(true)

	self.Description = self.Scroll:Add("ScribeLabel")
	self.Description:Dock(TOP)
	self.Description:SetAutoStretchVertical(true)

	self.Scroll:AddItem(self.Description)

	self:MakePopup()
	self:Center()
end

function PANEL:Setup(ply, description)
	local name = ply:VisibleRPName()

	if lp:IsAdmin() then
		name = string.format("%s - %s (%s)", name, ply:Nick(), ply:SteamID())
	end

	self:SetTopBar(name)

	self.Preview:SetPlayer(ply)
	self.CharacterName:SetText(ply:VisibleRPName())

	self.Description:SetText(string.format("<iset=2><small><cnormal>%s", description))
end

vgui.Register("GUI_Examine", PANEL, "CC_Frame")

ui.Register("Examine", function(ply, description)
	local panel = vgui.Create("GUI_Examine")

	panel:Setup(ply, description)

	return panel
end)

ExamineCache = ExamineCache or {}

FindMetaTable("Player").Examine = function(self)
	if self == lp then
		ui.Open("Examine", self, self:VisibleDescription())

		return
	end

	async.Start(function()
		local description = request.Send("Examine", self) or ExamineCache[self:SteamID()]

		ExamineCache[self:SteamID()] = description

		ui.Open("Examine", self, description)
	end)
end
