local PLAYER = FindMetaTable("Player")

PlayerVar.Add("ScoreboardTitle", {Default = "", Persist = true, DataType = VARCHAR(64)})
PlayerVar.Add("ScoreboardTitleC", {Default = Vector(255, 255, 255), Persist = true, DataType = BLOB()})

PlayerVar.Add("DonatorActive", {Default = false})

PlayerVar.Add("OOCMuted", {Default = 0, Persist = true, DataType = TINYINT()})

-- Todo: Implement weapon zoom as a multiplier
function PLAYER:GetSightRange()
	return Config.Get("PlayerSight")
end

function PLAYER:CanSee(target, checkSight)
	local startPos = self:EyePos()
	local pos = target

	if isentity(target) then
		pos = target:IsPlayer() and target:EyePos() or target:WorldSpaceCenter()
	end

	if checkSight and startPos:Distance(pos) > self:GetSightRange() then
		return false
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
	return not ply:IsRagdolled()
end

function GM:StartCommand(ply, cmd)
	if not ply:CanMove() then
		cmd:ClearMovement()
		cmd:ClearButtons()

		return
	end
end

function GM:FinishMove(ply, mv)
	if ply:IsRagdolled() then
		ply:SetNetworkOrigin(ply:GetRagdoll():GetNetworkOrigin())

		return true
	end
end

function GM:PlayerSwitchWeapon(ply, old, new)
	return not ply:CanAct()
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
	if ply:IsEFlagSet(EFL_NOCLIP_ACTIVE) or not ply:HasCharacter() then
		return true
	end

	if ply:IsRagdolled() and not RagdollDamage then
		return true
	end
end
