HUD.Name = "Progress Bars"

HUD.AlwaysDraw = true

HUD.Width = 400
HUD.Height = 40

HUD.Spacing = 60
HUD.Offset = 40

function HUD:Initialize()
end

local backgroundColor = Color("cc_fill_dark", 200)
local foregroundColor = Color(150, 20, 20)

local textColor = Color("cc_normal")

function HUD:Paint(w, h)
	local back = surface.GetFontHeight("CombineControl.LabelBig") * 0.5

	local width = ui.Scale(self.Width)
	local height = ui.Scale(self.Height)

	local spacing = ui.Scale(60)
	local offset = ui.Scale(40)

	local margin = ui.Scale(2)
	local margin2 = margin * 2

	local w2 = width * 0.5

	for k, data in ipairs(progress.Active) do
		local x = (w * 0.5) - w2
		local y = (h * 0.5) + offset + ((k - 1) * spacing)

		surface.SetDrawColor(backgroundColor)
		surface.DrawRect(x, y, width, height)

		surface.SetDrawColor(foregroundColor)
		surface.DrawRect(x + margin, y + margin, (width - margin2) * data.Fraction, height - margin2)

		draw.DrawText(data.Name or "N/A", "CombineControl.LabelBig", w * 0.5, y + height * 0.5 - back, textColor, TEXT_ALIGN_CENTER)
	end
end
