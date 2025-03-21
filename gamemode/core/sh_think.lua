if CLIENT then
	GM.VarSyncCache = GM.VarSyncCache or {}
end

local wheelSpeed = GetConVar("physgun_wheelspeed")

function GM:Think()
	self.BaseClass:Think()

	if CLIENT then
		if wheelSpeed:GetFloat() > 20 then
			RunConsoleCommand("physgun_wheelspeed", "20")
		end

		if #self.VarSyncCache > 0 then
			netstream.Send("RequestEntityVars", self.VarSyncCache)

			self.VarSyncCache = {}
		end
	else
		for _, ply in player.Iterator() do
			ply:UpdatePhysgunColor()
		end
	end
end

if SERVER then
	local PLAYER = FindMetaTable("Player")

	function PLAYER:UpdatePhysgunColor()
		local vec = Vector(0.30, 1.80, 2.10)

		if self:IsDeveloper() then
			for i = 1, 3 do
				vec[i] = math.abs(math.sin(CurTime() * 2.4 + (2 * i)))
			end
		elseif self:IsAdmin() or self:DonatorActive() then
			vec = Vector(self:GetInfo("cl_weaponcolor"))

			if vec:Length() < 0.001 then
				vec = Vector(0.001, 0.001, 0.001)
			end
		end

		if vec != self:GetWeaponColor() then
			self:SetWeaponColor(vec)
		end
	end
end
