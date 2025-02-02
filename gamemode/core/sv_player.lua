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
		async.Start(meta.LoadCharacter, ply, 2)

		return
	end

	ply:SetHolstered(true)
end

function GM:PlayerSpawn(ply)
	ply.SpawnPos = ply:GetPos()

	-- Might want to update the bird workflow at some point
	if not ply:HasCharacter() then
		ply:UpdateAppearance()

		ply:SetNotSolid(true)
		ply:SetMoveType(MOVETYPE_NOCLIP)

		return
	end

	ply:SetHolstered(true)

	ply:FullRestore()

	ply:SetNotSolid(false)
	ply:SetMoveType(MOVETYPE_WALK)

	ply:UpdateLoadout()
end

-- Todo: Expand on this
function GM:PlayerSelectSpawn(ply)
	return table.Random(ents.FindByClass("cc_spawnpoint")) or self.BaseClass.PlayerSelectSpawn(self, ply)
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
