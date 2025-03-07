module("Access", package.seeall)

Bans = Bans or {}

function LoadBans()
	Bans = {}

	local query = GAMEMODE.Database:Select("rp_bans")

	for _, ban in ipairs(query:Execute()) do
		Bans[ban.SteamID] = ban

		CheckBanned(ban.SteamID)
	end
end

function AddBan(steamid, admin, length, reason)
	if CheckBanned(steamid) then
		LiftBan(steamid)
	end

	local ban = {
		SteamID = steamid,
		Admin = IsValid(admin) and admin:GetAlias() or "CONSOLE",
		Timestamp = os.time(),
		Length = length,
		Reason = reason or "No reason specified"
	}

	local query = GAMEMODE.Database:Insert("rp_bans")
		query:Insert("SteamID", ban.SteamID)
		query:Insert("Admin", ban.Admin)
		query:Insert("Timestamp", ban.Timestamp)
		query:Insert("Length", ban.Length)
		query:Insert("Reason", ban.Reason)
	async.Start(function()
		query:Execute()
	end)

	Bans[steamid] = ban

	local ply = player.GetBySteamID(steamid)

	if ply then
		Log.Write("security_ban", admin, ply:Nick(), steamid, ban.Length, ban.Reason, false)

		ply:Kick(GetBanMessage(ban))
	else
		Log.Write("security_ban", admin, nil, steamid, ban.Length, ban.Reason, true)
	end
end

local permaFormat = [[
Permanently banned by %s:

%s]]

local normalFormat = [[
Banned by %s for %s:

%s

This ban will expire in %s]]

local kickFormat = [[
Kicked by %s:

%s]]

function GetBanMessage(ban)
	if ban.Length == 0 then
		return string.format(permaFormat,
			ban.Admin,
			ban.Reason)
	else
		return string.format(normalFormat,
			ban.Admin,
			string.NiceTime(ban.Length),
			ban.Reason,
			string.NiceTime(GetRemaining(ban)))
	end
end

function GetRemaining(ban)
	return ban.Timestamp + ban.Length - os.time()
end

function CheckBanned(steamid)
	local ban = Bans[steamid]

	if ban then
		if ban.Length > 0 and GetRemaining(ban) < 0 then
			LiftBan(steamid)

			return false
		end

		return true, ban
	end

	return false
end

function LiftBan(steamid)
	local query = GAMEMODE.Database:Delete("rp_bans")
		query:WhereEqual("SteamID", steamid)
	async.Start(function()
		query:Execute()
	end)

	Bans[steamid] = nil
end

function Kick(admin, ply, reason)
	reason = reason or "No reason specified"

	Log.Write("security_kick", admin, ply, reason)

	ply:Kick(string.format(kickFormat, IsValid(admin) and admin:Nick() or "CONSOLE", reason))
end

function SecureAdmin(ply, endpoint)
	if not ply:IsAdmin() then
		Access.AddBan(ply:SteamID(), nil, 0, string.format("AUTOMATED: ACL bypass attempt (%s)", endpoint))

		return true
	end
end

function GM:CheckPassword(steam64, ip, sv, cl, nick)
	local steamid = util.SteamIDFrom64(steam64)
	local banned, ban = CheckBanned(steamid)

	if banned then
		Log.Write("security_deny_banned", nick, steamid)

		return false, GetBanMessage(ban)
	end

	-- if self.AutoMapOverride then
	-- 	game.ConsoleCommand("changelevel " .. self.AutoMapOverride .. "\n")
	-- 	self.AutoMapOverride = false -- just in case...
	-- end

	if #sv > 0 and cl != sv then
		Log.Write("security_deny_password", nick, steamid)

		return false, "#GameUI_ServerRejectBadPassword"
	end

	return true
end

request.Hook("RequestBans", function(ply, config)
	if Access.SecureAdmin(ply, "RequestBans") then
		return
	end

	return Bans
end)
