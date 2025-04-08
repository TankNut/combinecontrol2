local PLAYER = FindMetaTable("Player")

function GM:OnPlayerReady(ply)
	GlobalVar.Sync(ply)

	async.Start(function()
		PlayerVar.Load(ply)
		ply:LoadCharacterList()

		ply:SetLastNick(ply:Nick())
		ply:SetLastSeen(os.time())
	end)
end

function PLAYER:SetUsingSpawnCamera(enabled)
	local cameras = EntityCache.Get("worldents_spawncameras")

	if not enabled or table.IsEmpty(cameras) then
		self:SetViewEntity(self)

		return
	end

	local _, camera = table.Random(cameras)
	self:SetViewEntity(camera)
end

function PLAYER:FullRestore()
	self:SetHealth(self:GetMaxHealth())
	self:SetArmor(self:GetMaxArmor())

	self.DrownDamage = 0

	self:EndRagdoll()
end

function GM:PlayerInitialSpawn(ply)
	ply.ArmorFraction = 1

	ply:SetTeam(TEAM_UNASSIGNED)
	ply:SetMaxArmor(0)

	-- Holdover from TRP, do we want to keep this?
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)

	ply:SetDuckSpeed(0.3)
	ply:SetUnDuckSpeed(0.3)

	ply:SetNoCollideWithTeammates(false)
	ply:SetAvoidPlayers(false)

	ply:AllowFlashlight(true)

	ply:SetCustomCollisionCheck(true)
	ply:SetCanZoom(false)
	ply:Freeze(true)

	ply.AFKTime = CurTime()
end

function GM:PlayerSpawn(ply)
	ply.ArmorFraction = 1

	-- Might want to update the bird workflow at some point
	if not ply:HasCharacter() then
		ply:UpdateAppearance()

		ply:SetNotSolid(true)
		ply:SetNoTarget(true)
		ply:SetMoveType(MOVETYPE_NOCLIP)

		ply:SetUsingSpawnCamera(true)

		return
	end

	ply:FullRestore()

	ply:SetNotSolid(false)
	ply:SetNoTarget(false)
	ply:SetMoveType(MOVETYPE_WALK)

	ply:UpdateLoadout(true)

	ply:SetUsingSpawnCamera(false)

	Npc.HandlePlayerSpawn(ply)
end

if not PLAYER._SetMaxArmor then
	PLAYER._SetMaxArmor = PLAYER.SetMaxArmor
end

function PLAYER:SetMaxArmor(val)
	self:_SetMaxArmor(val)
	self:SetArmor(math.min(self.ArmorFraction * val, val))
end

function GM:PlayerPostThink(ply)
	local max = ply:GetMaxArmor()

	if max > 0 then
		ply.ArmorFraction = math.Clamp(ply:Armor() / max, 0, 1)
	end
end

function GM:PlayerDisconnected(ply)
	ply:SetLastSeen(os.time())
	ply:SetCharacterLastSeen(os.time())
end

function GM:DoPlayerDeath(ply, attacker, dmg)
	if not ply:IsRagdolled() then
		ply:CreateRagdoll()
	end

	ply:RunCharFlag("OnDeath")

	if IsValid(attacker) and attacker:IsPlayer() and attacker != ply then
		local weapon = dmg:GetInflictor()

		if weapon:IsPlayer() and IsValid(weapon:GetActiveWeapon()) then
			weapon = weapon:GetActiveWeapon()
		end

		if IsValid(weapon) then
			Log.Write("sandbox_kill", attacker, ply, weapon:GetClass())
		end
	end
end

local function writeDeathLog(log)
	Log.WriteHint(log)
	netstream.Broadcast("WriteHint", log)
	MsgAll(log .. "\n")
end

function GM:PlayerDeath(ply, inflictor, attacker)
	-- Don't spawn for at least 2 seconds
	ply.NextSpawnTime = CurTime() + 2
	ply.DeathTime = CurTime()

	if not ply:HasCharacter() then
		return
	end

	if IsValid(attacker) then
		if attacker:GetClass() == "trigger_hurt" then
			attacker = ply
		end

		if attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
			attacker = attacker:GetDriver()
		end

		if not IsValid(inflictor) then
			inflictor = attacker
		end
	end

	if IsValid(inflictor) and inflictor == attacker and inflictor:IsPlayer() then
		inflictor = inflictor:GetActiveWeapon()

		if not IsValid(inflictor) then
			inflictor = attacker
		end
	end

	if attacker == ply then
		writeDeathLog(ply:VisibleRPName() .. " suicided!")
	elseif attacker:IsPlayer() then
		writeDeathLog(string.format("%s killed %s using %s", attacker:VisibleRPName(), ply:VisibleRPName(), inflictor:GetClass()))
	else
		if not IsValid(attacker) then
			attacker = game.GetWorld()
		end

		writeDeathLog(string.format("%s was killed by %s", ply:VisibleRPName(), attacker:GetClass()))
	end
end

function GM:PlayerSelectSpawn(ply)
	local overrideSpawns = {}
	local groupSpawns = {}
	local teamSpawns = {}
	local fallbackSpawns = {}

	for spawn in pairs(EntityCache.Get("spawns")) do
		if not spawn:IsSaved() then
			continue
		end

		if spawn.Mode == SPAWN_FALLBACK then
			table.insert(fallbackSpawns, spawn)
		elseif spawn.Mode == SPAWN_TEAM and spawn:GetTeam() == ply:Team() then
			table.insert(teamSpawns, spawn)
		elseif spawn.Mode == SPAWN_GROUP and ply:RunCharFlag("AllowSpawngroups") and spawn:GetGroup() == ply:Spawngroup() then
			table.insert(groupSpawns, spawn)
		elseif spawn.Mode == SPAWN_OVERRIDE then
			table.insert(overrideSpawns, spawn)
		end
	end

	local spawns

	if #overrideSpawns > 0 then
		spawns = overrideSpawns
	elseif #groupSpawns > 0 then
		spawns = groupSpawns
	elseif #teamSpawns > 0 then
		spawns = teamSpawns
	elseif #fallbackSpawns > 0 then
		spawns = fallbackSpawns
	end

	if spawns then
		local preferred = {}

		for _, spawn in ipairs(spawns) do
			if not spawn:IsOccupied() and not spawn:IsBlocked() then
				table.insert(preferred, spawn)
			end
		end

		if #preferred > 0 then
			return table.Random(preferred)
		else
			return table.Random(spawns)
		end
	end

	return self.BaseClass.PlayerSelectSpawn(self, ply)
end

function GM:GetPlayerLoadout(ply)
	local tab = {}

	local config = Config.Get("ToolTrust")
	local trust = ply:GetToolTrust()

	if trust >= config.Physgun then
		table.insert(tab, "weapon_physgun")
	end

	if trust >= config.Toolgun then
		table.insert(tab, "gmod_tool")
	end

	return tab
end

function GM:BlockFallDamage(ply)
	return ply:RunCharFlag("NoFallDamage")
end

function GM:GetFallDamage(ply, speed)
	if hook.Run("BlockFallDamage", ply) then
		return 0
	end

	local damage = (speed - 526.5) * (100 / 200)

	if damage <= 0 then
		return 0
	end

	hook.Run("OnTakeFallDamage", ply, damage)

	return damage
end

function GM:CanPlayerSuicide(ply)
	if not ply:HasCharacter() then
		return false
	end

	return true
end

function GM:PlayerSpray(ply)
	return true
end

function GM:PlayerCanHearPlayersVoice(targ, ply)
	return false
end

function GM:PlayerDeathSound()
	return true
end

function GM:AllowPlayerPickup(ply, ent)
	return false
end

function GM:PlayerUse(ply, ent)
	for _, func in ipairs({Buttons.OnUse}) do
		local val = func(ply, ent)

		if val != nil then
			return val
		end
	end

	return true
end

function GM:PlayerSetHandsModel(ply, ent)
	ent:SetModel("models/weapons/c_arms_citizen.mdl")
	ent:SetSkin(0)
	ent:SetBodyGroups("11")
end

hook.Add("player_changename", "core/player", function(data)
	Player(data.userid):SetLastNick(data.newname)
end)

