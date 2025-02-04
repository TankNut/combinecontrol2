local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

PlayerVar.Add("ToolTrust", {Default = TOOLTRUST_UNTRUSTED, Persist = true, DataType = TINYINT()})

function GM:GetToolTrust(ply)
	if ply:IsDeveloper() then
		return TOOLTRUST_DEVELOPER
	end

	if ply:IsAdmin() then
		return TOOLTRUST_ADMIN
	end

	return ply:ToolTrust()
end

function PLAYER:GetToolTrust()
	return hook.Run("GetToolTrust", self)
end

function ENTITY:IsProtectedEntity()
	-- Permaprops return true

	local class = self:GetClass()

	for _, v in ipairs(Config.Get("ProtectedEntities")) do
		if string.find(class, v) then
			return true
		end
	end

	return false
end

function GM:CanUseTool(ply, tool)
	local convar = GetConVar("toolmode_allow_" .. tool)

	if convar and not convar:GetBool() then
		return false, "#spawnmenu.tools.disabled"
	end

	local config = Config.Get("ToolTrust")
	local requirement = config.Tools[tool] or config.ToolFallback

	return ply:GetToolTrust() >= requirement, "You're not allowed to use this tool!z"
end

function GM:CanTool(ply, tr, tool)
	if not hook.Run("CanUseTool", ply, tool) then
		return false
	end

	local ent = tr.Entity

	if IsValid(ent) then
		if ent:IsPlayer() and ply:GetToolTrust() < Config.Get("ToolTrust").ToolgunPlayers then
			return false
		end

		if ent:IsProtectedEntity() then
			return false
		end

		if ent.CanTool and not ent.CanTool(ply, tool) then
			return false
		end
	end

	return true
end

function GM:PhysgunPickup(ply, ent)
	if ent:IsProtectedEntity() or (ent.CanPhys and not ent:CanPhys(ply)) then
		return false
	end

	local config = Config.Get("ToolTrust")
	local trust = ply:GetToolTrust()

	if ent:IsPlayer() and trust >= config.PhysgunPlayers and ply:CanTarget(ent) then
		ent:SetMoveType(MOVETYPE_NONE)

		return true
	end

	return true
end

function GM:PhysgunDrop(ply, ent)
	if ply:GetToolTrust() < Config.Get("ToolTrust").FlingEntities then
		ent:SetVelocity(vector_origin)
	end

	if ent:IsPlayer() then
		ent:SetMoveType(MOVETYPE_WALK)
	end
end

function GM:PlayerSpawnObject(ply, mdl, skin)
	if IsUselessModel(mdl) then
		return false
	end

	if ply:GetToolTrust() >= Config.Get("ToolTrust").BypassBlacklist then
		return true
	end

	for _, v in ipairs(Config.Get("ToolTrust")) do
		if string.find(string.lower(mdl), v) then
			return false
		end
	end

	return true
end

function GM:CanArmDupe(ply)
	return false
end

function GM:PlayerCheckLimit(ply, name, current, default)
	local limit = Config.Get("Limits")[name] or default or 0
	local multiplier = Config.Get("LimitMultipliers")[ply:GetToolTrust()]

	if limit == -1 or multiplier == -1 then
		return true
	end

	return current < math.floor(limit * multiplier)
end

function GM:CanDrive(ply, ent)
	return false
end

-- Prop ownership
if SERVER then
	if not cleanup.ccAdd then
		cleanup.ccAdd = cleanup.Add
	end

	function cleanup.Add(ply, name, ent)
		-- Set owner

		return cleanup.ccAdd(ply, name, ent)
	end

	if not PLAYER.ccAddCount then
		PLAYER.ccAddCount = PLAYER.AddCount
	end

	function PLAYER:AddCount(name, ent)
		-- Set owner

		return PLAYER.ccAddCount(self, name, ent)
	end
end
