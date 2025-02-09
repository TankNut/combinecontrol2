local ENTITY = FindMetaTable("Entity")

function ENTITY:GetPlayerColor()
	if self:IsFakePlayer() then
		return self:GetFakePlayer():GetPlayerColor()
	end

	return Vector(0.2, 0.2, 0.2)
end

function GM:InitPostEntity()
	-- Legacy code
	hook.Run("CC.SH.InitEnts")

	-- Legacy code ends
	if CLIENT then
		Settings.LoadClient()

		return
	end

	hook.Run("LoadDatabase")
end

function GM:OnEntityCreated(ent)
	if not IsValid(ent) then
		return
	end

	if CLIENT and ent:EntIndex() > 0 then
		table.insert(self.VarSyncCache, ent)
	end

	if ent:IsPlayer() then
		Inventory.Init(ent)
	end

	if SERVER and ent:IsNPC() then
		ent:SetKeyValue("spawnflags", bit.band(ent:GetSpawnFlags(), SF_NPC_NO_WEAPON_DROP))
	end
end

function GM:EntityRemoved(ent, fullUpdate)
	if fullUpdate then
		return
	end

	if ent:IsPlayer() then
		Inventory.Clear(ent, true)
		CharacterVar.Clear(ent)
		PlayerVar.Clear(ent)
	else
		EntityVar.Clear(ent)

		if SERVER and ent:IsFakePlayer() then
			local ply = ent:GetFakePlayer()

			ply:Kill()
		end
	end
end

if SERVER then
	function GM:EntityTakeDamage(ent, dmg)
		if ent:IsFakePlayer() and not dmg:IsDamageType(DMG_CRUSH) then
			RagdollDamage = true
				ent:FakePlayer():TakeDamageInfo(dmg)
			RagdollDamage = nil

			return true
		end
	end

	netstream.Hook("RequestEntityVars", function(ply, entities)
		for _, ent in ipairs(entities) do
			if not IsValid(ent) then
				continue
			end

			if ent:IsPlayer() then
				PlayerVar.Sync(ent, ply)
				CharacterVar.Sync(ent, ply)
			else
				EntityVar.Sync(ent, ply)
			end
		end
	end)
end
