local tooltrustNames = {
	[TOOLTRUST_BANNED] = "<c=error>Banned</c>",
	[TOOLTRUST_UNTRUSTED] = "Untrusted",
	[TOOLTRUST_TRUSTED] = "<c=orange>Trusted</c>",
	[TOOLTRUST_ADVANCED] = "<c=green>Advanced</c>",
	[TOOLTRUST_ADMIN] = "<c=hotpink>Admin</c>",
	[TOOLTRUST_DEVELOPER] = "<c=dodgerblue>Developer</c>"
}

local usergroupNames = {
	user = "User",
	admin = "<c=hotpink>Admin</c>",
	superadmin = "<c=gold>Superadmin</c>",
	developer = "<c=dodgerblue>Developer</c>"
}

local donatorNames = {
	[DONATOR_NONE] = "No",
	[DONATOR_BASIC] = "<c=dodgerblue>Basic</c>",
	[DONATOR_ADVANCED] = "<c=gold>Advanced</c>"
}

local playerInfo = console.AddCommand("rpa_player_info", function(ply, steamID)
	local record = Data.Player.Fetch(steamID)

	if not record then
		console.Feedback(ply, "ERROR", "No record exists for this player!")

		return
	end

	local lines = {}
	local len = 0

	local function addLine(title, contents, ...)
		if contents then
			len = math.max(len, #title)
		end

		table.insert(lines, {title, contents and string.format(contents, ...) or nil})
	end

	addLine("Basic Info")

	addLine("SteamID", steamID)
	addLine("Name", #record.LastNick > 0 and record.LastNick or "<c=error>*UNKNOWN*</c>")

	if #record.Alias > 0 then
		addLine("Alias", record.Alias)
	end

	if IsValid(player.GetBySteamID(steamID)) then
		addLine("Last Online", "<c=lime>Now</c>")
	else
		addLine("Last Online", record.LastSeen and string.NiceTime(os.time() - record.LastSeen) .. " ago" or "<c=error>Never</c>")
	end

	local usergroup = record.UserGroup
	local tooltrust = record.ToolTrust

	if usergroup == "developer" then
		tooltrust = TOOLTRUST_DEVELOPER
	elseif usergroup == "superadmin" or usergroup == "admin" then
		tooltrust = TOOLTRUST_ADMIN
	end

	addLine("UserGroup", usergroupNames[usergroup])

	addLine("Misc Info")
	addLine("ToolTrust", tooltrustNames[tooltrust])

	local badges

	if table.Count(record.CustomBadges) > 0 then
		local custom = {}

		for _, badge in pairs(Badge.List) do
			if record.CustomBadges[badge.ID] then
				table.insert(custom, badge.Name)
			end
		end

		badges = table.concat(custom, "<c=white>,</c> ")
	else
		badges = "None"
	end

	addLine("Badges", badges)

	local permissions

	if table.Count(record.Permissions) > 0 then
		local set = {}

		for permission in SortedPairs(record.Permissions) do
			table.insert(set, permission)
		end

		permissions = table.concat(set, "<c=white>,</c> ")
	else
		permissions = "None"
	end

	addLine("Permissions", permissions)

	local donator = (record.DonationLevel > 0 and os.time() <= record.DonationExpire) and record.DonationLevel or DONATOR_NONE

	addLine("Contributor", donatorNames[donator])

	if donator > DONATOR_NONE then
		addLine("Until", "%s (%s remaining)", os.date("%Y-%m-%d %H:%M:%S", record.DonationExpire), string.NiceTime(record.DonationExpire - os.time()))
	end

	addLine("OOC Muted", record.OOCMuted and "<c=error>Yes</c>" or "<c=lime>No</c>")

	addLine("Bans")

	local ban = Access.Bans[steamID]
	local banned = ban and (ban.Length == 0 or Access.GetRemaining(ban) > 0)

	addLine("Banned", banned and "<c=error>Yes</c>" or "<c=lime>No</c>")

	if banned then
		addLine("Timestamp", "%s (%s ago)", os.date("%Y-%m-%d %H:%M:%S", ban.Timestamp), string.NiceTime(os.time() - ban.Timestamp))

		if ban.Length > 0 then
			addLine("Length", "%s (%s remaining)", string.NiceTime(ban.Length), string.NiceTime(Access.GetRemaining(ban)))
		else
			addLine("Length", "<c=error>Permanent</c>")
		end

		addLine("Admin", ban.Admin)
		addLine("Reason", ban.Reason)
	end

	for k, v in ipairs(lines) do
		local title = v[1]
		local contents = v[2]

		if not contents then
			lines[k] = string.format("<c=white>== %s ==</c>", title)
		else
			lines[k] = string.format("  <c=white>%s:</c>%s %s", title, string.rep(" ", len - #title), contents)
		end
	end

	console.Feedback(ply, "CONSOLE", table.concat(lines, "\n"))
end)

playerInfo:SetCategory("Player Commands")
playerInfo:SetDescription("Look up info about a player or SteamID")
playerInfo:SetExecutionContext(console.Server)
playerInfo:SetAccess(console.IsAdmin)

playerInfo:AddParameter(console.SteamID())





local listCharacters = console.AddCommand("rpa_character_list", function(ply, steamID)
	local target = player.GetBySteamID(steamID)
	local name = string.format("%s (%s)", IsValid(target) and target:Nick() or Data.Player.Nick(steamID), steamID)
	local characters = GAMEMODE.Database:Query("SELECT `id`, COALESCE(`NameOverride`, `Name`) AS `Name`, `Flag`, `EventCharacter` FROM rp_characters WHERE `SteamID` = :steamID AND `Deleted_At` IS NULL", {
		steamID = steamID
	})

	if #characters < 1 then
		console.Feedback(ply, "ERROR", "No characters exist for %s!", name)

		return
	end

	local defaultFlag = CharacterFlag.Get(GAMEMODE.DefaultFlag)
	local lines = {string.format("<c=white>-- Character list for: %s (%d character%s) --</c>", name, #characters, #characters > 1 and "s" or "")}

	for _, character in pairs(characters) do
		local flag = character.Flag and CharacterFlag.Get(character.Flag) or defaultFlag
		local color = team.GetColor(flag.Team)

		color:SetBrightness(1)

		table.insert(lines, string.format("  CharID %d: <c=%s>%s</c>%s - %s%s",
			character.id,
			color,
			character.Name,
			character.NameOverride and " (" .. character.NameOverride .. ")" or "",
			flag.Name or flag.ClassName,
			character.EventCharacter and " (EVENT CHARACTER)" or ""
		))
	end

	console.Feedback(ply, "CONSOLE", table.concat(lines, "\n"))
end)

listCharacters:SetCategory("Character Commands")
listCharacters:SetDescription("Lists all characters owned by a player")
listCharacters:SetExecutionContext(console.Server)
listCharacters:SetAccess(console.IsAdmin)

listCharacters:AddParameter(console.SteamID())





local characterInfo = console.AddCommand("rpa_character_info", function(ply, id)
	local record = Data.Character.Fetch(id)

	if not record then
		console.Feedback(ply, "ERROR", "There is no character with that ID!")

		return
	end

	local lines = {}
	local len = 0

	local function addLine(title, contents, ...)
		if contents then
			len = math.max(len, #title)
		end

		table.insert(lines, {title, contents and string.format(contents, ...) or nil})
	end

	addLine("Ownership")

	addLine("Character ID", record.id)
	addLine("SteamID", record.SteamID)
	addLine("Name", Data.Player.Nick(record.SteamID))
	addLine("Event Character", record.IsEventCharacter and "<c=error>Yes</c>" or "<c=lime>No</c>")

	addLine("Age")
	addLine("Created", "%s (%s ago)", os.date("%Y-%m-%d %H:%M:%S", record.Created_At), string.NiceTime(os.time() - record.Created_At))

	if record.Deleted then
		addLine("Deleted", "<c=error>Yes</c>, %s ago (%s)", string.NiceTime(os.time() - record.Deleted_At), os.date("%Y-%m-%d %H:%M:%S", record.Deleted_At))
		addLine("Age", "%s old", string.NiceTime(record.Deleted_At - record.Created_At))
	else
		addLine("Deleted", "<c=lime>No</c>")
		addLine("Age", "%s old", string.NiceTime(os.time() - record.Created_At))
	end

	if Character.GetByID(id) then
		addLine("Last Seen", "<c=lime>Now</c>")
	else
		addLine("Last Seen", "%s (%s ago)", os.date("%Y-%m-%d %H:%M:%S", record.CharacterLastSeen), string.NiceTime(os.time() - record.CharacterLastSeen))
	end

	addLine("Basic Info")
	addLine("Character Name", #record.CharacterNameOverride > 0 and record.CharacterNameOverride .. " <c=error>(Override)</c>" or record.CharacterName)
	addLine("Description", #record.CharacterDescription > 0 and record.CharacterDescription or "<c=error>N/A</c>")

	local flag = CharacterFlag.Get(record.CharacterFlag or GAMEMODE.DefaultFlag)
	local color = team.GetColor(flag.Team)
	color:SetBrightness(1)

	addLine("Flag", "<c=%s>%s</c>", color, flag.Name or flag.ClassName)
	addLine("Model", #record.CharacterModelOverride > 0 and record.CharacterModelOverride .. " <c=error>(Override)</c>" or record.CharacterModel)
	addLine("Skin", record.CharacterSkin)
	addLine("Scale", record.CharacterScale == 0 and "Not Set" or record.CharacterScale)

	for k, v in ipairs(lines) do
		local title = v[1]
		local contents = v[2]

		if not contents then
			lines[k] = string.format("<c=white>== %s ==</c>", title)
		else
			lines[k] = string.format("  <c=white>%s:</c>%s %s", title, string.rep(" ", len - #title), contents)
		end
	end

	console.Feedback(ply, "CONSOLE", table.concat(lines, "\n"))
end)

characterInfo:SetCategory("Character Commands")
characterInfo:SetDescription("Look up info about a character")
characterInfo:SetExecutionContext(console.Server)
characterInfo:SetAccess(console.IsAdmin)

characterInfo:AddParameter(console.Number({validate.Min(1)}))
