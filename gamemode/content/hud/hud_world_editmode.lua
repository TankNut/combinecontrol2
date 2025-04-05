local BaseClass = inherit.Get("hud", "base")

HUD.Name = "Edit Mode"

function HUD:ShouldAddElement()
	if not lp:IsAdmin() then
		return false
	end

	return BaseClass.ShouldAddElement(self)
end

function HUD:ShouldDraw()
	if not lp:EditMode() then
		return false
	end

	return BaseClass.ShouldDraw(self)
end

local offset = Vector(0.1, 0.1, 0.1)

function HUD:DrawButtons()
	for button in Buttons.Iterator() do
		if not IsValid(button) or button:IsDormant() then
			continue
		end

		local color = Buttons.GetAccessType(button).Color

		local mins = button:OBBMins()
		local maxs = button:OBBMaxs()

		mins:Sub(offset)
		maxs:Add(offset)

		render.SetColorMaterial()
		render.DrawBox(button:GetPos(), button:GetAngles(), mins, maxs, color, true)
	end
end

function HUD:PostDrawTranslucentRenderables(depth, skybox)
	if skybox then
		return
	end

	self:DrawButtons()
end
