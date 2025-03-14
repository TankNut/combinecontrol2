HUD.Name = "Health"

HUD.Default = true
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
	local y = self:GetCache("LOffset", 0)

	if y == 0 then
		y = h - 20
	else
		y = y - 10
	end

	do
		local ratio = math.min(self.HP / lp:GetMaxHealth(), 1)

		self:DrawAlignedRect(20, y, self.Width, self.Height, self.BackgroundColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		self:DrawAlignedRect(22, y - 2, (self.Width - 4) * ratio, self.Height - 4, self.HealthColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

		y = y - self.Height - 2
	end

	if self.Armor >= 0.5 then
		local baseRatio = math.min(self.Armor / 100, 1)

		self:DrawAlignedRect(20, y, self.Width, self.Height, self.BackgroundColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		self:DrawAlignedRect(22, y - 2, (self.Width - 4) * baseRatio, self.Height - 4, self.ArmorColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

		if self.Armor > 100 then
			local extraRatio = math.min((self.Armor - 100) / 100, 1)

			self:DrawAlignedRect(22, y - 2, (self.Width - 4) * extraRatio, self.Height - 4, self.OverArmorColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		end

		y = y - self.Height - 2
	end

	self:SetCache("LOffset", y + 2) -- Compensate for the -2 margin
end
