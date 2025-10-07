HUD.Name = "Character Info"

HUD.Setting = "CharacterInfo"

HUD.DrawOrder = 0

HUD.BoxColor = Color("cc_fill_dark", 200)

function HUD:Paint(w, h)
	local offset = ui.Scale(20)
	local margin = ui.Scale(2)

	local x, y = offset, h - offset

	local nameScribe = scribe.Parse("<giant><ol><c=cc_normal>" .. lp:VisibleRPName())
	local teamScribe = scribe.Parse("<giant><ol><c=cc_normal>" .. team.GetName(lp:Team()))

	local scribeW = math.max(nameScribe:GetWide(), teamScribe:GetWide())
	local scribeH = nameScribe:GetTall() + teamScribe:GetTall()

	local boxW = math.max(scribeW + margin * 2, 220)
	local boxH = scribeH + margin * 2

	self:DrawAlignedRect(x, y, boxW, boxH, self.BoxColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

	nameScribe:Draw(x + boxW - margin, y - boxH + margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	teamScribe:Draw(x + boxW - margin, y - margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

	self:SetCache("LOffset", y - boxH)
end
