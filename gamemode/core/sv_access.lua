module("Access", package.seeall)

Bans = Bans or {}

function LoadBans()
	Bans = {}

	local query = GAMEMODE.Database:Select("rp_bans")

	for _, ban in ipairs(query:Execute()) do
		Bans[ban.SteamID] = ban

		CheckBanned(ban.Steamid)
	end
end

function AddBan(steamid, admin, length, reason)
	if CheckBanned(steamid) then
		LiftBan(steamid)
	end

	local ban = {
		SteamID = steamid,
		Admin = IsValid(admin) and admin:Nick() or "CONSOLE", -- Todo: Admin aliases
		AdminID = IsValid(admin) and admin:SteamID() or "CONSOLE",
		Timestamp = os.time(),
		Length = length,
		Reason = reason or "No reason specified"
	}

	local query = GAMEMODE.Database:Insert("rp_bans")
		query:Insert("SteamID", ban.SteamID)
		query:Insert("Admin", ban.Admin)
		query:Insert("AdminID", ban.AdminID)
		query:Insert("Timestamp", ban.Timestamp)
		query:Insert("Length", ban.Length)
		query:Insert("Reason", ban.Reason)
	async.Start(function()
		query:Execute()
	end)

	Bans[steamid] = ban

	local ply = player.GetBySteamID(steamid)

	if ply then
		ply:Kick(GetBanMessage(ban))
	end
end

local permaFormat = [[
Permanently banned by %s:

%s]]

local normalFormat = [[
Banned by %s for %s:

%s

This ban will expire in %s]]

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

function GM:CheckPassword(steam64, ip, sv, cl, nick)
	local steamid = util.SteamIDFrom64(steam64)
	local banned, ban = CheckBanned(steamid)

	if banned then
		return false, GetBanMessage(ban)
	end

	-- if self.AutoMapOverride then
	-- 	game.ConsoleCommand("changelevel " .. self.AutoMapOverride .. "\n")
	-- 	self.AutoMapOverride = false -- just in case...
	-- end

	if #sv > 0 and cl != sv then
		return false, "#GameUI_ServerRejectBadPassword"
	end

	return true
end
