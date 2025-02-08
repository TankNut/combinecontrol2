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
