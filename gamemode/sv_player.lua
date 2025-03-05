local PLAYER = FindMetaTable("Player")

function GM:IsSpawnpointSuitable(ply, spawn, force)
	if ply:Team() == TEAM_SPECTATOR then return true end

	local pos = spawn:GetPos()
	local blockers = ents.FindInBox(pos + Vector(-16, -16, 0), pos + Vector(16, 16, 64))

	for _, blocker in pairs(blockers) do
		if IsValid(blocker) and blocker:IsPlayer() and blocker:Alive() and blocker != ply then
			return force
		end
	end

	return true
end

hook.Add("CC.SV.PlayerThink", "physgun", function(plys)
	for i = 1, #plys do
		local ply = plys[i]

		ply:SetPhysgunColor()
	end
end)

function PLAYER:SetPhysgunColor()
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

	self:SetWeaponColor(vec)
end

function GM:PlayerSay(ply, text, t)
	return ""
end

function GM:PlayerDeathSound()
	return true
end

hook.Add("EntityTakeDamage", "SV.Player.EntityTakeDamage", function(ent, dmginfo)
	if ent.NoDamage then
		dmginfo:ScaleDamage(0)

		return true
	end

	if ent:IsVehicle() and IsValid(ent:GetDriver()) then
		-- HACK! source appears to do some very strange fuckery with vehicle bullet damage
		if dmginfo:IsBulletDamage() and dmginfo:GetDamage() < 1 then
			dmginfo:ScaleDamage(10000)
		end

		if ent:GetClass():lower() == "gmod_sent_vehicle_fphysics_base" then
			return
		end

		if dmginfo:IsBulletDamage() then
			dmginfo:ScaleDamage(0.10)
		end
	end

	local blacklist =
		DMG_BURN +
		DMG_FALL +
		DMG_SHOCK +
		DMG_DROWN +
		DMG_PARALYZE +
		DMG_NERVEGAS +
		DMG_POISON +
		DMG_ACID

	if ent:IsPlayer() and bit.band(blacklist, dmginfo:GetDamageType()) != dmginfo:GetDamageType() then
		if ent:IsEFlagSet(EFL_NOCLIP_ACTIVE) or ent:Team() == TEAM_UNASSIGNED then
			dmginfo:ScaleDamage(0)

			return
		end

		local dmg = dmginfo:GetDamage()
		local mult = ent:LastHitGroup() == HITGROUP_HEAD and 1.2 or 1
		local count = 1

		if GAMEMODE.ShotgunDamage then
			count = dmg / GAMEMODE.ShotgunDamage
			dmg = GAMEMODE.ShotgunDamage
		end

		if dmg == 0 then
			return true
		end

		dmg = dmg * count

		dmginfo:SetDamage(dmg * mult)
	end

	if ent:IsPlayer() then
		ent.NextHealthRegen = CurTime() + 30
	end

	if ent:IsNPC() and not dmginfo:GetAttacker():IsNPC() then
		ent:AddEntityRelationship(dmginfo:GetAttacker(), D_HT, 99)
	end
end)

function GM:DoPlayerDeath(ply, attacker, dmg)
	if ply.Inventory then
		for _, v in pairs(ply.Inventory) do
			v:OnPlayerDeath(ply)
		end
	end

	if not ply:IsRagdolled() then
		ply:CreateRagdoll()
	end

	local func = ply:RunCharFlag("OnDeath")

	if func then
		func(ply)
	end

	if attacker and attacker:IsPlayer() and attacker != ply then
		local weapon = dmg:GetInflictor()

		if not IsValid(weapon) then
			return
		end

		if weapon:IsPlayer() then
			weapon = weapon:GetActiveWeapon():GetClass()
		else
			weapon = weapon:GetClass()
		end
	end

	hook.Run("CC.SV.PlayerDeath", ply)
end

function GM:ScaleNPCDamage(ply, hitgroup, dmginfo)
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if attacker:GetClass() == "prop_physics" or attacker:GetClass() == "prop_ragdoll" or attacker:GetClass() == "cc_item" then return false end

	return true
end

function GM:PlayerDisconnected(ply)
	ply:SetLastSeen(os.time())

	if ply:Ragdoll() and ply:Ragdoll():IsValid() then
		ply:Ragdoll():Remove()
	end
end

function GM:ShutDown()
	GAMEMODE.IsShuttingDown = true

	hook.Run("CC.SV.ShutDown")
end
