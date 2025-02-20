local PLAYER = FindMetaTable("Player")

PlayerVar.Add("UserGroup", {
	Default = "user",
	ServerOnly = false,
	Persist = true,
	DataType = VARCHAR(64)
})

PlayerVar.Add("TempAdmin", {
	Default = false,
	ServerOnly = true,
	Persist = false
})

GlobalVar.Add("OOCDelay", {Default = 0})

GlobalVar.Add("AIDisabled", {Default = false})
GlobalVar.Add("AINoTarget", {Default = false})

local immunity = {
	user = 0,
	admin = 1,
	superadmin = 2
}

function PLAYER:CanTarget(target)
	if self:IsDeveloper() then
		return true
	end

	return (immunity[self:UserGroup()] or 0) >= (immunity[target:UserGroup()] or 0)
end

function PLAYER:IsAdmin()
	return self:IsDeveloper() or self:IsSuperAdmin() or self:UserGroup() == "admin"
end

function PLAYER:IsSuperAdmin()
	return self:IsDeveloper() or self:UserGroup() == "superadmin"
end

function PLAYER:IsDeveloper()
	return self:UserGroup() == "developer"
end

function PLAYER:IsUserGroup(group)
	return self:UserGroup() == group
end

PLAYER.GetUserGroup = PLAYER.UserGroup

function GM:PlayerNoClip(ply, state)
	if not ply:IsAdmin() then
		if CLIENT and IsFirstTimePredicted() then
			lp:SendChat("ERROR", "You need to be an admin to do this!")
		end

		return false
	end

	if ply:IsRagdolled() then
		if CLIENT and IsFirstTimePredicted() then
			lp:SendChat("ERROR", "You cannot noclip while ragdolled!")
		end

		return false
	end

	if SERVER then
		if state then
			ply:SetNoTarget(true)
			ply:SetNotSolid(true)
			ply:SetNoDraw(true)
		else
			ply:SetNoTarget(false)
			ply:SetNotSolid(false)
			ply:SetNoDraw(false)
		end
	end

	return true
end

if SERVER then
	hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")

	function GM:OnAIDisabledChanged(old, new, loaded)
		RunConsoleCommand("ai_disabled", new and 1 or 0)
	end

	function GM:OnAINoTargetChanged(old, new, loaded)
		RunConsoleCommand("ai_ignoreplayers", new and 1 or 0)
	end
end
