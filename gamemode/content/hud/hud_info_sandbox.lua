local BaseClass = inherit.Get("hud", "base")

HUD.Name = "Sandbox Info"

HUD.Default = true
HUD.Setting = "SandboxInfo"
HUD.DrawOrder = 0

HUD.ExtraSettings = {
	{"ShowWarning", {
		Name = "    Show Warning",
		ClientOnly = true,
		Default = true,
		Validate = validate.Bool(),
		Panel = "CC_Setting_Bool",
		Dark = true
	}}
}

HUD.Limits = {
	"props",
	"effects",
	"ragdolls"
}

HUD.BoxColor = Color("cc_fill_dark", 200)

function HUD:ShouldDraw()
	local weapon = lp:GetActiveWeapon()

	if not IsValid(weapon) or not WEAPONS_TOOLS[weapon:GetClass()] then
		return false
	end

	return BaseClass.ShouldDraw(self)
end

function HUD:DrawWarning(w, h, baseOffset, rightOffset, margin)
	local toolScribe = scribe.Parse("<giant><ol><c=cc_bad>One of your building tools is visible on your character!")
	local oocScribe = scribe.Parse("<giant><ol><c=cc_bad>You will be considered out-of-character until it is put away!")

	local warningScribeW = math.max(toolScribe:GetWide(), oocScribe:GetWide())
	local warningScribeH = toolScribe:GetTall() + oocScribe:GetTall()

	local warningBoxW = warningScribeW + margin * 2
	local warningBoxH = warningScribeH + margin * 2

	local x, y = w - baseOffset - warningBoxW, h - baseOffset - rightOffset

	self:DrawAlignedRect(x, y, warningBoxW, warningBoxH, self.BoxColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

	toolScribe:Draw(x + warningBoxW - margin, y - warningBoxH + margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	oocScribe:Draw(x + warningBoxW - margin, y - margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

	return warningBoxH + 10
end

function HUD:DrawLimits(w, h, baseOffset, rightOffset, margin)
	local limitLines = {}
	local limitScribeW = 0
	local limitScribeH = 0
	local limitOffset = 0

	for _, limit in ipairs(self.Limits) do
		local default = Config.Get("Limits")[limit] or 0
		local multiplier = Config.Get("LimitMultipliers")[lp:GetToolTrust()]

		local limitScribe = scribe.Parse(string.format("<giant><ol><c=cc_normal>%s: %s%s",
			string.FirstToUpper(limit),
			lp:GetCount(limit),
			(default == -1 or multiplier == -1) and "" or "/" .. math.floor(default * multiplier)))

		table.insert(limitLines, limitScribe)

		limitScribeW = math.max(limitScribeW, limitScribe:GetWide())
		limitScribeH = limitScribeH + limitScribe:GetTall()
	end

	local limitBoxW = limitScribeW + margin * 2
	local limitBoxH = limitScribeH + margin * 2

	local x, y = w - baseOffset - limitBoxW, h - baseOffset - rightOffset

	self:DrawAlignedRect(x, y, limitBoxW, limitBoxH, Color("cc_fill_dark", 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

	for _, limitScribe in ipairs(limitLines) do
		limitScribe:Draw(x + limitBoxW - margin, y - limitBoxH + margin - limitOffset, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

		limitOffset = limitOffset - limitScribe:GetTall()
	end

	return y - limitBoxH
end

function HUD:Paint(w, h)
	local baseOffset = 20
	local rightOffset = 0
	local margin = 2

	if self:GetExtraSetting("ShowWarning") then
		rightOffset = self:DrawWarning(w, h, baseOffset, rightOffset, margin)
	end

	rightOffset = self:DrawLimits(w, h, baseOffset, rightOffset, margin)

	self:SetCache("ROffset", rightOffset)
end
