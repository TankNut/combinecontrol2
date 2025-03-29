local firemodes = {
	[FIREMODE_AUTO] = "Automatic",
	[FIREMODE_SEMI] = "Semi-Automatic",
	[FIREMODE_SAFE] = "Safe"
}

function SWEP:GetFiremodeName()
	local index = self:GetFiremode()

	return firemodes[index] and firemodes[index] or index .. "-Round Burst"
end

function SWEP:GetHUDLines()
	local ammo = string.format("<f=CombineControl.Ammo><ol><c=cc_normal>%s/%s", self:Clip1(), self.Primary.ClipSize)
	local firemode = "<f=CombineControl.AmmoSmall><ol><c=cc_normal>" .. self:GetFiremodeName()

	return {ammo, firemode}
end
