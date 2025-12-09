local PANEL = {}

AccessorFunc(PANEL, "_State", "State")

function PANEL:Init()
	self:SetState(false)

	self.Primary = Color(150, 20, 20)
	self.PrimaryDark = Color(60, 0, 0)

	self.FillLight = Color(60, 60, 60)
	self.FillMedium = Color(40, 40, 40)
	self.FillDark = Color(30, 30, 30)
end

function PANEL:DoClick()
	local state = not self:GetState()

	self:SetState(state)

	if state then
		self:OnEnable()
	else
		self:OnDisable()
	end

	self:OnToggle(state)
end

function PANEL:OnEnable()
end

function PANEL:OnDisable()
end

function PANEL:OnToggle()
end

function PANEL:Paint(w, h)
	local fill

	if self:GetDisabled() then
		fill = self.FillDark
	else
		fill = self:GetState() and self.Primary or self.FillLight
	end

	surface.SetDrawColor(fill)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(self:GetState() and self.PrimaryDark or self.FillMedium)
	surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("CC_ToggleButton", PANEL, "DButton")
