local wheelSpeed = GetConVar("physgun_wheelspeed")

function GM:Think()
	self.BaseClass:Think()

	if CLIENT then
		if wheelSpeed:GetFloat() > 20 then
			RunConsoleCommand("physgun_wheelspeed", 20)
		end

		Ambience.Think()
	else
		for _, ply in player.Iterator() do
			ply:UpdatePhysgunColor()
		end

		Npc.CheckHeldWeapons()
		Doors.UpdateDoors()
		Inventory.Think()
	end
end

if SERVER then
	local PLAYER = FindMetaTable("Player")

	function PLAYER:UpdatePhysgunColor()
		local vec = self:GetSetting("PhysgunColor"):ToVector()

		if self:GetSetting("RainbowPhysgun") then
			for i = 1, 3 do
				vec[i] = math.abs(math.sin(CurTime() * 2.4 + (2 * i)))
			end
		end

		if vec != self:GetWeaponColor() then
			self:SetWeaponColor(vec)
		end
	end
end
