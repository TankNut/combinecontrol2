local BaseClass = inherit.Get("hud", "base")

HUD.Name = "Edit Mode"

function HUD:ShouldAddElement()
	return lp:IsAdmin()
end

function HUD:ShouldDraw()
	if not lp:EditMode() then
		return false
	end

	return BaseClass.ShouldDraw(self)
end

function HUD:PaintBackground(w, h)
end
