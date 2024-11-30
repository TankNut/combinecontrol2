local meta = FindMetaTable("Player")

function GM:OnPlayerReady(ply)
	GlobalVar.Sync(ply)

	async.Start(function()
		PlayerVar.Load(ply)
		ply:LoadCharacterList()
	end)
end

function meta:FullRestore()
	self:SetHealth(self:GetMaxHealth())
	self:SetArmor(self:GetMaxArmor())

	self.DrownDamage = 0

	self:SetConsciousness(100)
	self:WakeUp(true)

	-- This needs to be done better
	if IsValid(self:Ragdoll()) then
		self:Ragdoll():Remove()
	end
end

function GM:PlayerInitialSpawn(ply)
	if not self.FullyLoaded then
		self:LogBug("ERROR: PlayerInitialSpawn on player " .. ply:Nick() .. " before gamemode fully loaded.")

		return
	end

	ply:SetTeam(TEAM_UNASSIGNED)

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

	if ply:IsBot() then
		return
	end

	ply:SetHolstered(true)
end

function GM:PlayerSpawn(ply)
	-- Might want to update the bird workflow at some point
	if not ply.FirstSpawn then
		ply.FirstSpawn = true

		ply:SetModel(table.Random({"models/crow.mdl", "models/pigeon.mdl", "models/seagull.mdl"}))

		--ply:LoadPlayerNotes()

		ply:SetNotSolid(true)
		ply:SetMoveType(MOVETYPE_NOCLIP)

		ply.SpawnPos = ply:GetPos()

		return
	end

	ply:SetHolstered(true)

	ply:FullRestore()

	ply:SetNotSolid(false)
	ply:SetMoveType(MOVETYPE_WALK)

	ply:UpdateLoadout()

	if respawn then
		local ent = ply:RunCharFlag("UseCombineSpawns") and "cc_spawnpoint_skynet" or "cc_spawnpoint"
		local spawn = table.Random(ents.FindByClass(ent))

		if IsValid(spawn) then
			ply:SetPos(spawn:GetPos())
			ply:SetEyeAngles(spawn:GetAngles())
		end

		local offset = ply:RunCharFlag("SpawnOffset")

		if offset then
			ply:SetPos(ply:GetPos() + offset)
		end

		ply.SpawnPos = ply:GetPos()
	end

	self:RefreshNPCRelationships()
end

function GM:GetPlayerLoadout(ply)
	-- Needs to take into account tooltrust/phystrust
	return {"weapon_physgun", "gmod_tool"}
end
