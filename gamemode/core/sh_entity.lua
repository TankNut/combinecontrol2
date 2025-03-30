local ENTITY = FindMetaTable("Entity")

EntityCache.Add("npcs", function(ent) return ent:IsNPC() end)

function ENTITY:GetPlayerColor()
	if self:IsFakePlayer() then
		return self:GetFakePlayer():GetPlayerColor()
	end

	return Vector(0.2, 0.2, 0.2)
end

function GM:InitPostEntity()
	if CLIENT then
		Settings.LoadClient()
		RunConsoleCommand("spawnmenu_reload")

		if Settings.Get("Thirdperson") then
			ctp:Enable()
		end

		return
	end

	hook.Run("LoadDatabase")
end

function GM:OnEntityCreated(ent)
	if not IsValid(ent) then
		return
	end

	EntityCache.OnCreated(ent)

	if CLIENT and ent:EntIndex() > 0 then
		table.insert(self.VarSyncCache, ent)
	end

	if ent:IsPlayer() then
		Inventory.Init(ent)
		ent:SetupDataTables()
	end

	if SERVER then
		if ent:IsNPC() then
			Npc.OnCreated(ent)
		elseif ent:IsRagdoll() then
			ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end
	end
end

function GM:EntityRemoved(ent, fullUpdate)
	if fullUpdate then
		return
	end

	EntityCache.OnRemoved(ent)

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

function GM:PreRegisterSWEP(_, class)
	if SERVER then
		timer.Simple(0, function()
			-- Only firearms can be wielded by NPC's, because reasons
			if not weapons.IsBasedOn(class, "weapon_cc_base_gun") then
				return
			end

			local weapon = weapons.Get(class)

			if weapon.Settings.NoNPC then
				return
			end

			list.Add("NPCUsableWeapons", {
				title = weapon.PrintName,
				class = class,
			})
		end)
	end
end

if SERVER then
	function GM:EntityTakeDamage(ent, dmginfo)
		if ent:IsPlayer() then
			return hook.Run("PlayerTakeDamage", ent, dmginfo)
		end

		if ent:IsFakePlayer() and not dmginfo:IsDamageType(DMG_CRUSH) then
			RagdollDamage = true
				ent:FakePlayer():TakeDamageInfo(dmginfo)
			RagdollDamage = nil

			return true
		end
	end

	function GM:PostEntityTakeDamage(ent, dmginfo, wasTaken)
		if ent:IsNPC() then
			Npc.OnDamaged(ent, dmginfo)
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
