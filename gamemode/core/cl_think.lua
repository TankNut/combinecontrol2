GM.VarSyncCache = GM.VarSyncCache or {}

local wheelSpeed = GetConVar("physgun_wheelspeed")

function GM:Think()
	self.BaseClass:Think()

	-- Legacy code
	self:MusicThink()
	self:CreateParticleEmitters()
	self:ToggleHolsterThink()

	hook.Run("PlayerThink", player.GetAll())
	-- Legacy code ends

	if wheelSpeed:GetFloat() > 20 then
		RunConsoleCommand("physgun_wheelspeed", "20")
	end

	if #self.VarSyncCache > 0 then
		netstream.Send("RequestEntityVars", self.VarSyncCache)

		table.Empty(self.VarSyncCache)
	end
end
