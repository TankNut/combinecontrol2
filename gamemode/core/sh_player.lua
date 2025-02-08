local PLAYER = FindMetaTable("Player")

PlayerVar.Add("ScoreboardTitle", {Default = "", Persist = true, DataType = VARCHAR(64)})
PlayerVar.Add("ScoreboardTitleC", {Default = Vector(255, 255, 255), Persist = true, DataType = BLOB()})

PlayerVar.Add("DonatorActive", {Default = false})

PlayerVar.Add("OOCMuted", {Default = 0, Persist = true, DataType = TINYINT()})

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

if CLIENT then
	function GM:PrePlayerDraw(ply, flags)
		if ply:IsRagdolled() then
			return true
		end
	end
end
