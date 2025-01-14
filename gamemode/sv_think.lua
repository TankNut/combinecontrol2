function GM:Think()
	local plys = player.GetAll()
	hook.Run("CC.SV.PlayerThink", plys)
	hook.Run("PlayerThink", plys)
end
