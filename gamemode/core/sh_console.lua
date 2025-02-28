local COMMAND = CustomMetaTable("ConsoleCommand")

function COMMAND:SetCategory(category)
	self.Category = category
end

function COMMAND:SetChatAlias(alias)
	Chat.AddConsoleCommand(alias, self.Name)
end

function console.PrintMessage(ply, str, ...)
	console.Feedback(ply, "NOTICE", str, ...)
end

function console.PrintError(ply, str, ...)
	console.Feedback(ply, "ERROR", str, ...)
end

function console.Feedback(ply, messageType, str, ...)
	local class = assert(Chat.List[messageType], "Invalid message type")

	if not IsValid(ply) then
		MsgC(class.ConsoleColor or class.Color, console.FormatMessage(str, ...), "\n")

		return
	end

	if CLIENT then
		lp:SendChat(messageType, console.FormatMessage(str, ...))
	elseif istable(ply) then
		local formattedMessage = console.FormatMessage(str, ...)

		for _, v in ipairs(ply) do
			v:SendChat(messageType, formattedMessage)
		end
	else
		ply:SendChat(messageType, console.FormatMessage(str, ...))
	end
end

function console.IsAdmin(ply) return ply:IsAdmin() end
function console.IsSuperAdmin(ply) return ply:IsSuperAdmin() end
function console.IsDeveloper(ply) return ply:IsDeveloper() end

function console.RPName(ply)
	return IsValid(ply) and ply:VisibleRPName() or "CONSOLE"
end

function console.FindPlayer(ply, str, options)
	if not str or #str < 1 then
		return false, "No target found"
	end

	local isConsole = not IsValid(ply)

	str = string.lower(str)

	local targets = {}
	local multi = false

	if str == "^" then -- Target self
		if isConsole then
			return false, "The server console cannot target itself"
		end

		if options.NoSelfTarget then
			return false, "You cannot target yourself"
		end

		table.insert(targets, ply)
	elseif str == "-" then -- Target look-at
		if isConsole then
			return false, "The server console cannot target by look-at"
		end

		local ent = ply:GetEyeTrace().Entity

		if IsValid(ent) and ent:IsPlayer() then
			table.insert(targets, ent)
		end
	elseif str[1] == "$" then -- Target by radius
		if isConsole then
			return false, "The server console cannot target by radius"
		end

		multi = true

		local radius, targetSelf = string.match(str, "^%$([%d]+)(%+?)$")

		radius = tonumber(radius)
		targetSelf = targetSelf == "+"

		if not radius then
			return false, "Invalid radius"
		end

		local eye = ply:EyePos()

		for _, target in player.Iterator() do
			if (target != ply or targetSelf) and ply:EyePos():Distance(eye) <= radius then
				table.insert(targets, target)
			end
		end
	-- Disabled, infrastructure for searching teams by name isn't ready atm
	-- elseif str[1] == "#" then -- Target by team
	elseif str == "@@" then -- Target everyone
		multi = true
		targets = player.GetAll()
	else -- Target by name
		multi = str[1] == "@"

		if multi then
			str = string.sub(str, 2)
		end

		for _, target in player.Iterator() do
			if target:HasCharacter() and string.find(string.lower(target:VisibleRPName()), str, 1, not multi) then
				table.insert(targets, target)

				continue
			end

			if (isConsole or ply:IsAdmin()) and string.find(string.lower(target:Nick()), str, 1, not multi) then
				table.insert(targets, target)

				continue
			end

			if (isConsole or ply:IsAdmin()) and string.find(string.lower(target:SteamID()), str, 1, not multi) then
				table.insert(targets, target)

				continue
			end
		end
	end

	if options.CheckImmunity and not isConsole then
		targets = table.Filter(targets, function(_, target)
			return ply:CanTarget(target)
		end)
	end

	if options.StrictImmunity and not isConsole then
		targets = table.Filter(targets, function(_, target)
			return ply:CanTarget(target, true)
		end)
	end

	if options.NoAdmins then
		targets = table.Filter(targets, function(_, target)
			return not target:IsAdmin()
		end)
	end

	if options.NoSelfTarget and not isConsole then
		targets = table.Filter(targets, function(_, target)
			return target != ply
		end)
	end

	if table.IsEmpty(targets) then
		return false, "No targets found"
	elseif (not multi or options.SingleTarget) and #targets > 1 then
		return false, "Multiple matches found"
	end

	if options.SingleTarget then
		return true, targets[1]
	end

	return true, targets
end

console.Parser("Player", function(ply, args, last, options)
	return console.FindPlayer(ply, console.ReadArg(args, last), options)
end)

console.Parser("SteamID", function(ply, args, last, options)
	local val = console.ReadArg(args, last)

	if util.IsValidSteamID(val) and not options.Online then
		return true, val
	end

	options = table.Copy(options)
	options.SingleTarget = true

	local ok, target = console.FindPlayer(ply, val, options)

	-- Target will be an error message if ok is false
	return ok, ok and target:SteamID() or target
end)

if CLIENT then
	local col = Color(200, 200, 200)

	local function printItemList(name)
		if name then
			MsgC(col, string.format("ITEM LIST: (FILTER \"%s\")\n", name))
		else
			MsgC(col, "ITEM LIST:\n")
		end

		for class, item in SortedPairs(Item.Find(lp, name)) do
			local rarity = Item.Rarities[item.Rarity]

			MsgC("  ", col, class, " - ", rarity.Color or col, item.Name, "\n")
		end
	end

	netstream.Hook("ItemList", printItemList)
end

console.Parser("Item", function(ply, args, last, options)
	local itemList = function(name)
		if name == "" then
			name = nil
		end

		if CLIENT then
			printItemList(name)
		else
			netstream.Send(ply, "ItemList", name)
		end
	end

	local val = console.ReadArg(args, last)
	local items = Item.Find(ply, val)

	if table.Count(items) == 1 then
		return true, table.GetKeys(items)[1]
	end

	itemList(val)

	return true, nil
end)

console.Parser("Language", function(ply, args, last, options)
	local val = console.ReadArg(args, last)

	if not val or #val < 1 or not Language.Get(val) then
		return false, "Must be a valid language"
	end

	return true, val
end)

console.Parser("Badge", function(ply, args, last, options)
	local val = console.ReadArg(args, last)

	if not val or #val < 1 then
		return false, "Must be a valid badge"
	end

	local badge = Badge.Get(val)

	if not badge or badge.Automatic then
		return false, "Must be a valid badge"
	end

	return true, val
end)

console.Parser("Duration", function(ply, args, last, options)
	local val = console.ReadArg(args, last)
	local duration = util.Duration(val, options.OutputFormat)

	if not duration then
		return false, "Invalid duration"
	end

	if options.Min and duration < util.Duration(options.Min, options.OutputFormat) then
		return false, "Duration must be at least " .. options.Min
	end

	if options.Max and duration > util.Duration(options.Max, options.OutputFormat) then
		return false, "Duration can't be longer than " .. options.Max
	end

	return true, duration
end)

console.Parser("CharacterFlag", function(ply, args, last, options)
	local val = console.ReadArg(args, last)

	if not val or #val < 1 or not CharacterFlag.Get(val) then
		return false, "Must be a valid character flag"
	end

	return true, val
end)
