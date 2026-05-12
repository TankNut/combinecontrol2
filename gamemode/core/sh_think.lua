local wheelSpeed = GetConVar("physgun_wheelspeed")

function GM:Think()
	self.BaseClass:Think()

	if CLIENT then
		if wheelSpeed:GetFloat() > 20 then
			RunConsoleCommand("physgun_wheelspeed", 20)
		end

		Ambience.Think()

		for _, ply in player.Iterator() do
			ply:UpdatePhysgunColor()
		end
	else
		Npc.CheckHeldWeapons()
		Doors.UpdateDoors()
		Inventory.Think()
	end
end

if CLIENT then
	local PLAYER = FindMetaTable("Player")
	local defaultColor = Color(36, 219, 255)

	function GM:GetPhysgunColor(ply)
		return defaultColor
	end

	local weaponColor = Vector()

	function PLAYER:UpdatePhysgunColor()
		local col = hook.Run("GetPhysgunColor", self)

		weaponColor.x = col.r / 255
		weaponColor.y = col.g / 255
		weaponColor.z = col.b / 255

		if self:GetSetting("RainbowPhysgun") then
			for i = 1, 3 do
				weaponColor[i] = math.abs(math.sin(CurTime() * 2.4 + (2 * i)))
			end
		end

		if weaponColor != self:GetWeaponColor() then
			self:SetWeaponColor(weaponColor)
		end
	end
end
