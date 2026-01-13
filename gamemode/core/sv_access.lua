module("Access", package.seeall)

Bans = Bans or {}

function LoadBans()
	Bans = {}

	local query = GAMEMODE.Database:Query("SELECT * FROM `rp_bans`")

	for _, ban in ipairs(query) do
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

	async.Start(function()
		GAMEMODE.Database:Query("INSERT INTO `rp_bans` (`SteamID`, `Admin`, `Timestamp`, `Length`, `Reason`) VALUES (:steamId, :admin, :timestamp, :length, :reason)", {
			steamId = ban.SteamID,
			admin = ban.Admin,
			timestamp = ban.Timestamp,
			length = ban.Length,
			reason = ban.Reason
		})
	end)

	Bans[steamid] = ban

	Log.Write("access_ban", admin, steamid, ban.Length, ban.Reason)

	local ply = player.GetBySteamID(steamid)

	if ply then
		ply:Kick(GetBanMessage(ban))
	end
end

local permaFormat = [[Permanently banned by %s: %s]]
local normalFormat = [[Banned by %s for %s: %s

This ban will expire in %s]]

local kickFormat = [[Kicked by %s: %s]]

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

function LiftBan(steamid, admin)
	async.Start(function()
		GAMEMODE.Database:Query("DELETE FROM `rp_bans` WHERE `SteamID` = :steamId", {
			steamId = steamid
		})
	end)

	Log.Write("access_unban", admin, steamid)

	Bans[steamid] = nil
end

function Kick(admin, ply, reason)
	reason = reason or "No reason specified"

	Log.Write("access_kick", admin, ply, reason)

	ply:Kick(string.format(kickFormat, IsValid(admin) and admin:Nick() or "CONSOLE", reason))
end

function SecureAdmin(ply, endpoint)
	if not ply:IsAdmin() then
		AddBan(ply:SteamID(), nil, 0, string.format("AUTOMATED: ACL bypass attempt (%s)", endpoint))

		return true
	end
end

function SecureDeveloper(ply, endpoint)
	if not ply:IsDeveloper() then
		AddBan(ply:SteamID(), nil, 0, string.format("AUTOMATED: Developer ACL bypass attempt (%s)", endpoint))

		return true
	end
end

function GM:CheckPassword(steam64, ip, sv, cl, nick)
	local steamid = util.SteamIDFrom64(steam64)
	local banned, ban = CheckBanned(steamid)

	if banned then
		Log.Write("access_deny", nick, steamid, "banned")

		return false, GetBanMessage(ban)
	end

	if #sv > 0 and cl != sv then
		Log.Write("access_deny", nick, steamid, "bad password")

		return false
	end

	return true
end

request.Hook("RequestBans", function(ply, config)
	if Access.SecureAdmin(ply, "RequestBans") then
		return
	end

	return Bans
end)
