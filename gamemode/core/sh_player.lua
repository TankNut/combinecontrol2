local PLAYER = FindMetaTable("Player")

PlayerVar.Add("ScoreboardTitle", {Default = "", Persist = true, DataType = VARCHAR(64)})
PlayerVar.Add("ScoreboardTitleC", {Default = Vector(255, 255, 255), Persist = true, DataType = BLOB()})

PlayerVar.Add("DonatorActive", {Default = false})

PlayerVar.Add("OOCMuted", {Default = 0, Persist = true, DataType = TINYINT()})

PlayerVar.Add("Alias", {
	Default = "",
	Persist = true,
	DataType = VARCHAR(32)
})

PlayerVar.Add("LastNick", {
	Default = "",
	ServerOnly = true,
	Persist = true,
	DataType = VARCHAR(32)
})

PlayerVar.Add("LastSeen", {
	ServerOnly = true,
	Persist = true,
	DataType = UINT()
})

-- Todo: Implement weapon zoom as a multiplier
function PLAYER:GetSightRange()
	return Config.Get("PlayerSight")
end

function PLAYER:HasToolOut()
	local weapon = self:GetActiveWeapon()

	if IsValid(weapon) and WEAPONS_TOOLS[weapon:GetClass()] then
		return true
	end

	return false
end

function PLAYER:GetAlias()
	local alias = self:Alias()

	return #alias > 0 and alias or self:Nick()
end

function PLAYER:IsBlocking()
	local weapon = self:GetActiveWeapon()

	if not IsValid(weapon) then
		return false
	end

	if not weapon.GetBlockState then
		return false
	end

	return weapon:GetBlockState() > 0
end

function PLAYER:CanSee(target, checkSight)
	local startPos = self:EyePos()
	local pos = target

	if isentity(target) then
		pos = target:IsPlayer() and target:EyePos() or target:WorldSpaceCenter()
	end

	if checkSight then
		local dist = isnumber(checkSight) and checkSight or self:GetSightRange()

		if startPos:Distance(pos) > dist then
			return false
		end
	end

	local tr = util.TraceLine({
		start = self:EyePos(),
		endpos = pos,
		filter = self,
		mask = MASK_SOLID
	})

	return tr.Fraction == 1 or tr.Entity == target
end

function PLAYER:CanAct()
	return hook.Run("CanAct", self)
end

function GM:CanAct(ply)
	if not ply:HasCharacter() then
		return false
	end

	if ply:IsRagdolled() then
		return false
	end

	return true
end

function PLAYER:CanMove()
	return hook.Run("CanMove", self)
end

function GM:CanMove(ply)
	if ply:IsRagdolled() or not ply:HasCharacter() then
		return false
	end

	return true
end

function GM:StartCommand(ply, cmd)
	if not ply:CanMove() then
		cmd:ClearMovement()
		cmd:ClearButtons()

		return
	end
end

local function handle(ply, index, ...)
	local func = ply:RunCharFlag(index)

	if func then
		func(ply, ...)
	end

	local weapon = ply:GetActiveWeapon()

	if IsValid(weapon) and weapon:IsType("weapon_cc_base") and weapon[index] then
		weapon[index](weapon, ply, ...)
	end
end

function GM:SetupMove(ply, mv, cmd)
	local slow = Config.Get("SprintSlow")

	if slow < 1 and cmd:GetForwardMove() <= 0 then
		local speed = Lerp(slow, ply:GetWalkSpeed(), ply:GetRunSpeed())

		mv:SetMaxSpeed(speed)
		mv:SetMaxClientSpeed(speed)
	end

	handle(ply, "SetupMove", mv, cmd)

	return self.BaseClass:SetupMove(ply, mv, cmd)
end

function GM:Move(ply, mv)
	handle(ply, "Move", mv)

	return self.BaseClass:Move(ply, mv)
end

function GM:FinishMove(ply, mv)
	if ply:IsRagdolled() then
		ply:SetNetworkOrigin(ply:GetRagdoll():GetNetworkOrigin())

		return true
	end

	handle(ply, "FinishMove", mv)

	return self.BaseClass:FinishMove(ply, mv)
end

function GM:PlayerSwitchWeapon(ply, old, new)
	return not ply:CanAct()
end

function GM:PlayerTakeDamage(ply, dmginfo)
	if ply:IsEFlagSet(EFL_NOCLIP_ACTIVE) or not ply:HasCharacter() then
		return true
	end

	if ply:IsRagdolled() and not RagdollDamage then
		return true
	end

	if ply:IsBlocking() and dmginfo:IsDamageType(DMG_CLUB + DMG_SLASH) then
		dmginfo:ScaleDamage(ply:GetActiveWeapon().BlockMultiplier)
	end
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
	-- Todo: Headshot multipliers?
end
