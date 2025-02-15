CLASS.Name = "Character Info"

CLASS.Default = true
CLASS.Setting = "CharacterInfo"

CLASS.DrawOrder = 0

function CLASS:Initialize()
	self:UpdateInfo()

	hook.Add("OnVisibleRPNameChanged", self, self.OnVisibleRPNameChanged)

	self.Dark = Color("cc_dark")
end

function CLASS:OnVisibleRPNameChanged(ply, _, new)
	if ply == lp then
		self:UpdateInfo(new)
	end
end

function CLASS:UpdateInfo(name)
	self.LastName = name or lp:VisibleRPName()
	self.LastTeam = lp:Team()

	self.NameScribe = scribe.Parse("<giant><ol><c=cc_normal>" .. self.LastName)
	self.TeamScribe = scribe.Parse("<giant><ol><c=cc_normal>" .. team.GetName(self.LastTeam))
end

function CLASS:Think()
	if lp:Team() != self.LastTeam then
		self:UpdateInfo()
	end
end

function CLASS:Paint(w, h)
	local offset = 20
	local margin = 2

	local x, y = offset, h - offset

	local scribeW = math.max(self.NameScribe:GetWide(), self.TeamScribe:GetWide())
	local scribeH = self.NameScribe:GetTall() + self.TeamScribe:GetTall()

	local boxW = math.max(scribeW + margin * 2, 220)
	local boxH = scribeH + margin * 2

	self:DrawAlignedRect(x, y, boxW, boxH, Color("cc_fill_dark", 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

	self.NameScribe:Draw(x + boxW - margin, y - boxH + margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	self.TeamScribe:Draw(x + boxW - margin, y - margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

	self:SetCache("LOffset", offset + boxH)
end
