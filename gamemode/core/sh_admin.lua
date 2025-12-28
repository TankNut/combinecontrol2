local PLAYER = FindMetaTable("Player")

PlayerVar.Add("UserGroup", {
	Default = "user",
	ServerOnly = false,
	Persist = true,
	DataType = VARCHAR(64)
})

PlayerVar.Add("TempAdmin", {Default = false})
PlayerVar.Add("EditMode", {Default = false})

GlobalVar.Add("OOCDelay", {Default = 0})

GlobalVar.Add("AIDisabled", {Default = false})
GlobalVar.Add("AINoTarget", {Default = false})

GlobalVar.Add("AutoMapOverride", {
	ServerOnly = true,
	Persist = true
})

local immunity = {
	user = 0,
	admin = 1,
	superadmin = 2,
	developer = 3
}

function PLAYER:CanTarget(target, strict)
	return self:CanTargetUserGroup(target:UserGroup(), strict)
end

function PLAYER:CanTargetUserGroup(userGroup, strict)
	if self:IsDeveloper() then
		return true
	end

	local ourImmunity = immunity[self:UserGroup()] or 0
	local theirImmunity = immunity[userGroup] or 0

	if strict then
		return ourImmunity > theirImmunity
	else
		return ourImmunity >= theirImmunity
	end
end

function PLAYER:IsAdmin(strict)
	if not strict and self:TempAdmin() then
		return true
	end

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

if CLIENT then
	GM.SpawnmenuGroup = GM.SpawnmenuGroup or "user"

	function GM:UpdateSpawnmenu(usergroup)
		if usergroup != self.SpawnmenuGroup then
			self.SpawnmenuGroup = usergroup

			print("Reload")

			RunConsoleCommand("spawnmenu_reload")
		end
	end
end

function GM:OnUserGroupChanged(ply, old, new, loaded)
	if CLIENT and ply == lp then
		Hud.Rebuild()

		self:UpdateSpawnmenu(new)
	end
end

function GM:OnTempAdminChanged(ply, old, new, loaded)
	if CLIENT and ply == lp then
		Hud.Rebuild()

		self:UpdateSpawnmenu(new and "admin" or "user")
	end
end

if SERVER then
	hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")

	GM:SetAIDisabled(GetConVar("ai_disabled"):GetBool(), true)
	GM:SetAINoTarget(GetConVar("ai_ignoreplayers"):GetBool(), true)

	function GM:OnAIDisabledChanged(old, new, loaded)
		RunConsoleCommand("ai_disabled", new and 1 or 0)
	end

	function GM:OnAINoTargetChanged(old, new, loaded)
		RunConsoleCommand("ai_ignoreplayers", new and 1 or 0)
	end

	function GM:OnAutoMapOverrideChanged(old, new, loaded)
		if not loaded then
			return -- Only apply this when loading off the database. 
		end

		if new and new != game.GetMap() and table.HasValue(game.GetMapList(), new) then
			game.ConsoleCommand("changelevel " .. new .. "\n")
		end
	end

	request.Hook("AdminRoster", function(ply)
		if Access.SecureAdmin(ply, "AdminRoster") then
			return
		end

		return GAMEMODE.Database:Query("SELECT `SteamID`, `UserGroup`, `Alias`, `LastNick`, `LastSeen` FROM `rp_players` WHERE `UserGroup` IS NOT NULL")
	end)
end
