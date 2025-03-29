local BaseClass = inherit.Get("hud", "base")

HUD.Name = "Ammo"

HUD.Setting = "Ammo"

HUD.BoxColor = Color("cc_fill_dark", 200)

function HUD:ShouldDraw()
	if not BaseClass.ShouldDraw(self) then
		return false
	end

	local weapon = lp:GetActiveWeapon()

	if not IsValid(weapon) or not weapon:IsType("weapon_cc_base") then
		return false
	end

	return true
end

function HUD:Paint(w, h)
	local offset = 20
	local margin = 2

	local x, y = w - offset, h - offset

	local lines = lp:GetActiveWeapon():GetHUDLines()

	if not lines or #lines == 0 then
		return
	end

	for _, text in ipairs(lines) do
		local parsed = scribe.Parse(text)
		local width, height = parsed:GetSize()

		width = width + margin * 2
		height = height + margin * 2

		self:DrawAlignedRect(x - width, y, width, height, self.BoxColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

		parsed:Draw(x - margin, y - margin, 1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

		y = y - height
	end

	self:SetCache("ROffset", y)
end
