if CLIENT then
	GM.VarSyncCache = GM.VarSyncCache or {}
end

local wheelSpeed = GetConVar("physgun_wheelspeed")

function GM:Think()
	self.BaseClass:Think()

	hook.Run("PlayerThink", player.GetAll())

	if CLIENT then
		-- Legacy code
		self:MusicThink()
		self:CreateParticleEmitters()
		self:ToggleHolsterThink()
		-- Legacy code ends

		if wheelSpeed:GetFloat() > 20 then
			RunConsoleCommand("physgun_wheelspeed", "20")
		end

		if #self.VarSyncCache > 0 then
			netstream.Send("RequestEntityVars", self.VarSyncCache)

			self.VarSyncCache = {}
		end
	else
		hook.Run("CC.SV.PlayerThink", player.GetAll())
	end
end
