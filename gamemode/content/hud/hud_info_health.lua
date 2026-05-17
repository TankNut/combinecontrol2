HUD.Name = "Health"

HUD.Setting = "Health"

HUD.Width = 220
HUD.Height = 14

HUD.BackgroundColor = Color("cc_fill_dark", 200)

HUD.HealthColor = Color(150, 20, 20, 255)
HUD.ArmorColor = Color(37, 84, 158, 255)
HUD.OverArmorColor = Color(255, 255, 255, 255)

HUD.DrawOrder = 1

function HUD:Initialize()
	self.HP = lp:Health()
	self.Armor = lp:Armor()
end

function HUD:Think()
	self.HP = math.min(math.ApproachSpeed(self.HP, lp:Health(), 20), lp:GetMaxHealth())
	self.Armor = math.min(math.ApproachSpeed(self.Armor, lp:Armor(), 20), 200)
end

function HUD:Paint(w, h)
	local x = ui.Scale(20)
	local y = self:GetCache("LOffset", 0)

	if y == 0 then
		y = h - ui.Scale(20)
	else
		y = y - ui.Scale(10)
	end

	local width = ui.Scale(self.Width)
	local height = ui.Scale(self.Height)

	local border = ui.Scale(2)

	do
		local ratio = math.min(self.HP / lp:GetMaxHealth(), 1)

		self:DrawBar(ratio, x, y, width, height, border, self.BackgroundColor, self.HealthColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

		y = y - height - border
	end

	if self.Armor >= 0.5 then
		local baseRatio = math.min(self.Armor / 100, 1)

		self:DrawBar(baseRatio, x, y, width, height, border, self.BackgroundColor, self.ArmorColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

		if self.Armor > 100 then
			local extraRatio = math.min((self.Armor - 100) / 100, 1)

			self:DrawBar(extraRatio, x, y, width, height, border, nil, self.ArmorColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		end

		y = y - self.Height - border
	end

	self:SetCache("LOffset", y + border) -- Compensate for the margin
end
