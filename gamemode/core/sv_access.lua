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

function AddBan(steamID, nick, admin, length, reason)
	local ban = {
		SteamID = steamID,
		Admin = Log.AdminName(admin),
		Timestamp = os.time(),
		Length = length,
		Reason = reason or "No reason specified"
	}

	async.Start(function()
		GAMEMODE.Database:Query("DELETE FROM `rp_bans` WHERE `SteamID` = :steamID", {
			steamID = steamID
		})

		GAMEMODE.Database:Query("INSERT INTO `rp_bans` (`SteamID`, `Admin`, `Timestamp`, `Length`, `Reason`) VALUES (:steamID, :admin, :timestamp, :length, :reason)", {
			steamID = ban.SteamID,
			admin = ban.Admin,
			timestamp = ban.Timestamp,
			length = ban.Length,
			reason = ban.Reason
		})
	end)

	Bans[steamID] = ban

	Log.Write("access_ban", admin, steamID, nick, ban.Length, ban.Reason)

	local ply = player.GetBySteamID(steamID)

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

function CheckBanned(steamID)
	local ban = Bans[steamID]

	if ban then
		if ban.Length > 0 and GetRemaining(ban) < 0 then
			LiftBan(steamID)

			return false
		end

		return true, ban
	end

	return false
end

function LiftBan(steamID, admin)
	async.Start(function()
		GAMEMODE.Database:Query("DELETE FROM `rp_bans` WHERE `SteamID` = :steamID", {
			steamID = steamID
		})
	end)

	Log.Write("access_unban", admin, steamID, Data.Player.Nick(steamID))

	Bans[steamID] = nil
end

function Kick(admin, ply, reason)
	reason = reason or "No reason specified"

	Log.Write("access_kick", admin, ply, reason)

	ply:Kick(string.format(kickFormat, Log.AdminName(admin), reason))
end

function SecureAdmin(ply, endpoint)
	if not ply:IsAdmin() then
		AddBan(ply:SteamID(), ply:Nick(), nil, 0, string.format("AUTOMATED: ACL bypass attempt (%s)", endpoint))

		return true
	end
end

function SecureDeveloper(ply, endpoint)
	if not ply:IsDeveloper() then
		AddBan(ply:SteamID(), ply:Nick(), nil, 0, string.format("AUTOMATED: Developer ACL bypass attempt (%s)", endpoint))

		return true
	end
end

function GM:CheckPassword(steam64, ip, sv, cl, nick)
	local steamID = util.SteamIDFrom64(steam64)
	local banned, ban = CheckBanned(steamID)

	if banned then
		Log.Write("access_deny", nick, steamID, "banned")

		return false, GetBanMessage(ban)
	end

	if #sv > 0 and cl != sv then
		Log.Write("access_deny", nick, steamID, "bad password")

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
