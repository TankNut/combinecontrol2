local PLAYER = FindMetaTable("Player")

GM.CombineRadioFreq = 1000 -- dick weed

hook.Add("CC.SV.PlayerThink", "SV.Player.HealthThink", function(plys)
	for i = 1, #plys do
		local ply = plys[i]

		ply.NextHealthRegen = ply.NextHealthRegen or 0

		if ply.NextHealthRegen <= CurTime() and ply:Health() < ply:GetMaxHealth() and ply:Alive() then
			local rate = 2

			ply.NextHealthRegen = CurTime() + rate
			ply:SetHealth(ply:Health() + 1)
		end
	end
end)

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

function GM:KeyPress(ply, key)
	if key == IN_USE then
		local tr = self:GetHandTrace(ply, 100)

		if IsValid(tr.Entity) and tr.Entity:IsDoor() and tr.Entity:DoorType() == DOOR_COMBINEOPEN then
			tr.Entity:Fire("Open")
		end
	end
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

		self:LogSQL(string.format("Player %s (%s) killed player %s (%s) with %s.", attacker:Nick(), attacker:SteamID(), ply:Nick(), ply:SteamID(), weapon))

		self:WriteLog("sandbox_kill", {
			Ply = GAMEMODE:LogPlayer(attacker),
			Char = GAMEMODE:LogCharacter(attacker),
			VictimPly = GAMEMODE:LogPlayer(ply),
			VictimChar = GAMEMODE:LogCharacter(ply),
			Weapon = weapon
		})
	end

	net.Start("nSetNightvision")
		net.WriteBit(0)
	net.Send(ply)

	hook.Run("CC.SV.PlayerDeath", ply)
end

function GM:ScaleNPCDamage(ply, hitgroup, dmginfo)
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if attacker:GetClass() == "prop_physics" or attacker:GetClass() == "prop_ragdoll" or attacker:GetClass() == "cc_item" then return false end

	return true
end

function GM:PlayerDisconnected(ply)
	for _, v in pairs(game.GetDoors()) do
		if table.HasValue(v:DoorOwners(), ply:CharID()) then
			if table.Count(v:DoorOwners()) == 1 then
				ply:SellDoor(v)
			else
				ply:RemoveDoorOwner(v)
			end
		end
	end

	if ply:Ragdoll() and ply:Ragdoll():IsValid() then
		ply:Ragdoll():Remove()
	end
end

function GM:ShutDown()
	GAMEMODE.IsShuttingDown = true

	for _, ply in player.Iterator() do
		for _, v in pairs(game.GetDoors()) do
			if table.HasValue(v:DoorOwners(), ply:CharID()) then
				if table.Count(v:DoorOwners()) == 1 then
					ply:SellDoor(v)
				else
					ply:RemoveDoorOwner(v)
				end
			end
		end
	end

	hook.Run("CC.SV.ShutDown")
end

hook.Add("CC.SV.PlayerThink", "SV.Player.DrownThink", function(plys)
	for i = 1, #plys do
		local ply = plys[i]

		if not ply:Alive() then continue end

		local waterlevel = 3
		local targ = ply

		if ply:IsRagdolled() then
			waterlevel = 1
			targ = ply:GetRagdoll()
		end

		if targ:WaterLevel() < waterlevel then
			ply.AirFinished = CurTime() + 7

			if ply.DrownDamage and ply.DrownDamage > 0 then
				if not ply.PainFinished then
					ply.PainFinished = 0
				end

				if ply.PainFinished < CurTime() then
					ply.PainFinished = CurTime() + 1

					local dmg = DamageInfo()
					dmg:SetAttacker(game.GetWorld())
					dmg:SetDamage(10)
					dmg:SetDamageForce(Vector())
					dmg:SetDamagePosition(ply:GetPos())
					dmg:SetInflictor(game.GetWorld())
					dmg:SetDamageType(DMG_DROWN)

					GAMEMODE:EntityTakeDamage(ply, dmg)

					ply:SetHealth(ply:Health() + dmg:GetDamage())
					ply.DrownDamage = ply.DrownDamage - 10
				end
			end
		else
			if not ply:IsEFlagSet(EFL_NOCLIP_ACTIVE) and ply.AirFinished < CurTime() then
				if not ply.PainFinished then
					ply.PainFinished = 0
				end

				if ply.PainFinished < CurTime() then
					ply.PainFinished = CurTime() + 1

					local dmg = DamageInfo()
					dmg:SetAttacker(game.GetWorld())
					dmg:SetDamage(10)
					dmg:SetDamageForce(Vector())
					dmg:SetDamagePosition(ply:GetPos())
					dmg:SetInflictor(game.GetWorld())
					dmg:SetDamageType(DMG_DROWN)

					if not ply.DrownDamage then
						ply.DrownDamage = 0
					end

					ply.DrownDamage = math.min(ply.DrownDamage + 10, 50)
					ply:TakeDamageInfo(dmg)
				end
			end
		end
	end
end)

function PLAYER:HealOverTime(amount, rate, interval)
	self.HealRemaining = amount
	self.HealRate = rate
	self.HealInterval = interval
	self.NextHeal = CurTime()
end

hook.Add("CC.SV.PlayerThink", "SV.Player.HealThink", function(plys)
	for i = 1, #plys do
		local ply = plys[i]

		if not ply.HealRemaining or ply.HealRemaining <= 0 then
			continue
		end

		if ply:Health() >= ply:GetMaxHealth() or not ply:Alive() then
			ply.HealRemaining = 0

			continue
		end

		if not ply.NextHeal or ply.NextHeal > CurTime() then
			continue
		end

		local rate = ply.HealRate or 10 -- Amount of heals applied per tick
		local interval = ply.HealInterval or 1 -- Amount of seconds between each tick
		local amt = math.min(ply.HealRemaining, rate)

		ply.HealRemaining = ply.HealRemaining - amt
		ply.NextHeal = CurTime() + interval

		ply:SetHealth(math.min(ply:Health() + amt, ply:GetMaxHealth()))
	end
end)

net.Receive("nSetTyping", function(len, ply)
	local val = net.ReadFloat()
	ply:SetTyping(val)
end)

local function RollDice(ply, cmd, args)
	local errmessage = "rp_roll NdX+m -- N = # of dice, X = # of sides on dice, m = optional modifier\ne.g. rp_roll 2d20-4 will roll two d20's with a -4 modifier.\n"
	local num, sides, sign, mod

	if not args[1] then
		ply:PrintMessage(HUD_PRINTCONSOLE, errmessage)
		return
	end

	num, sides, sign, mod = string.match(args[1], "^ *(%d+)d(%d+) *([%+%-]?) *(%d*) *$")
	num, sides, mod = tonumber(num), tonumber(sides), tonumber(mod)

	if not (num and sides) then
		ply:PrintMessage(HUD_PRINTCONSOLE, errmessage)
		return
	end

	if num > 10 then
		ply:PrintMessage(HUD_PRINTCONSOLE, "Why would you need to roll more than 10 dice at once?\n")
		return
	end

	if sides > 1000 then
		ply:PrintMessage(HUD_PRINTCONSOLE, "How could you possibly roll a dice with that many sides?\n")
		return
	end

	local results, total = {}, 0
	for i = 1, num do
		local roll = math.random(sides)
		total = total + roll
		results[i] = roll
	end

	local mult, output
	local str = table.concat(results, " + ")

	if #sign > 0 and mode != 0 then
		mult = tonumber(sign .. mod)
		total = total + mult
		output = string.format("%s rolled %id%i%s%i: (%s) %s %i = %i", ply:VisibleRPName(), num, sides, sign, mod, str, sign, mod, total)
	else
		output = string.format("%s rolled %id%i: (%s) = %i", ply:VisibleRPName(), num, sides, str, total)
	end

	local rf = ply:GetRF(450, 450)
	Chat.Send(rf, "NOTICE", output)
end
concommand.Add("rp_roll", RollDice)
