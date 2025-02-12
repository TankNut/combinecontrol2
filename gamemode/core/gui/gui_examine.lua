local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 500)
	self:DockPadding(10, 10, 10, 10)

	self:SetCloseOnPause(true)
	self:SetDraggable(true)

	self.Preview = self:Add("CC_CharacterModel")
	self.Preview:DockMargin(0, 0, 20, 0)
	self.Preview:Dock(LEFT)
	self.Preview:SetWide(200)
	self.Preview:SetBaseYaw(20)

	self.CharacterName = self:Add("DLabel")
	self.CharacterName:DockMargin(0, 0, 0, 5)
	self.CharacterName:Dock(TOP)
	self.CharacterName:SetTall(22)
	self.CharacterName:SetFont("CombineControl.LabelGiant")

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:DockMargin(0, 0, 0, 0)
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

derma.DefineControl("GUI_Examine", "", PANEL, "CC_Frame")

GUI.Register("Examine", function(ply, description)
	local panel = vgui.Create("GUI_Examine")

	panel:Setup(ply, description)

	return panel
end)

ExamineCache = ExamineCache or {}

FindMetaTable("Player").Examine = function(self)
	if self == lp then
		GUI.Open("Examine", self, self:VisibleDescription())

		return
	end

	async.Start(function()
		local description = request.Send("Examine", self) or ExamineCache[self:SteamID()]

		ExamineCache[self:SteamID()] = description

		GUI.Open("Examine", self, description)
	end)
end
