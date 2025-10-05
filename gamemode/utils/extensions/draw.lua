function draw.Circle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {
		x = x,
		y = y,
		u = 0.5,
		v = 0.5
	})

	for i = 0, seg do
		local a = math.rad((i / seg) * -360)

		table.insert(cir, {
			x = x + math.sin(a) * radius,
			y = y + math.cos(a) * radius,
			u = math.sin(a) / 2 + 0.5,
			v = math.cos(a) / 2 + 0.5
		})
	end

	local a = math.rad(0) -- This is needed for non absolute segment counts

	table.insert(cir, {
		x = x + math.sin(a) * radius,
		y = y + math.cos(a) * radius,
		u = math.sin(a) / 2 + 0.5,
		v = math.cos(a) / 2 + 0.5
	})

	surface.DrawPoly(cir)
end

function draw.DrawTextShadow(text, font, x, y, col1, col2, align)
	if align != 0 then
		draw.DrawText(text, font, x + 1, y + 1, col2, align) -- Less efficient than surface, so we only use this if we need special alignment stuff.
		draw.DrawText(text, font, x, y, col1, align)
	else
		surface.SetFont(font)

		surface.SetTextColor(col2)
		surface.SetTextPos(x + 1, y + 1)
		surface.DrawText(text)
		surface.SetTextColor(col1)
		surface.SetTextPos(x, y)
		surface.DrawText(text)
	end
end

local matBlurScreen = Material("pp/blurscreen")

function draw.DrawBackgroundBlur(frac, x, y, w, h)
	DisableClipping(true)

	surface.SetMaterial(matBlurScreen)
	surface.SetDrawColor(255, 255, 255, 255)

	for i = 1, 3 do
		matBlurScreen:SetFloat("$blur", frac * 5 * (i / 3))
		matBlurScreen:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x or 0, y or 0, w or ScrW(), h or ScrH())
	end

	DisableClipping(false)
end
