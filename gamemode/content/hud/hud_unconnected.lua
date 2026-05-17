HUD.Name = "Unconnected"

HUD.AlwaysDraw = true

HUD.DrawOrder = math.huge

local textColor = Color("cc_normal")

function HUD:ShouldAddElement()
	return not lp:HasCharacter()
end

function HUD:ShouldDraw()
	return not lp:HasCharacter() and not vgui.CursorVisible()
end

function HUD:Initialize()
	-- For small maps / fast connections, avoid flashing "Loading..." for a moment; I think it just looks nicer.
	self.TextDelay = CurTime() + 5
end

function HUD:Paint(w, h)
	draw.DrawBackgroundBlur(1, 0, 0, w, h)

	if self.TextDelay < CurTime() then
		draw.DrawText("Loading...", "CombineControl.LabelGiant", w / 2, h / 2, textColor, 1)
	end
end
