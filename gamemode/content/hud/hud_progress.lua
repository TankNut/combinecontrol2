HUD.Name = "Progress Bars"

HUD.Default = true

HUD.Width = 400
HUD.Height = 40

HUD.Spacing = 60
HUD.Offset = 40

function HUD:Initialize()
end

local backgroundColor = Color("cc_fill_dark", 200)
local foregroundColor = Color(150, 20, 20)

local textColor = Color()
local back = surface.GetFontHeight("CombineControl.LabelBig") * 0.5

function HUD:Paint(w, h)
	local w2 = self.Width * 0.5

	for k, data in ipairs(progress.Active) do
		local x = (w * 0.5) - w2
		local y = (h * 0.5) + self.Offset + ((k - 1) * self.Spacing)

		surface.SetDrawColor(backgroundColor)
		surface.DrawRect(x, y, self.Width, self.Height)

		surface.SetDrawColor(foregroundColor)
		surface.DrawRect(x + 1, y + 1, (self.Width - 2) * data.Fraction, self.Height - 2)

		draw.DrawText(data.Name or "N/A", "CombineControl.LabelBig", w * 0.5, y + self.Height * 0.5 - back, textColor, TEXT_ALIGN_CENTER)
	end
end
