local PLAYER = FindMetaTable("Player")

if not PLAYER._SetMaxArmor then
	PLAYER._SetMaxArmor = PLAYER.SetMaxArmor
end

function PLAYER:SetMaxArmor(val)
	self:_SetMaxArmor(val)
	self:SetArmor(math.min(self.ArmorFraction * val, val))
end

hook.Add("PlayerPostThink", "plugins.armor", function(ply)
	local max = ply:GetMaxArmor()

	if max > 0 then
		ply.ArmorFraction = math.Clamp(ply:Armor() / max, 0, 1)
	end
end)

hook.Add("PlayerSpawn", "plugins.armor", function(ply)
	ply.ArmorFraction = 1
end)
