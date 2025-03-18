local restart = console.AddCommand("rpa_restart", function(ply)
	Chat.Send("GENERIC", {
		Text = console.FormatMessage("<giant>%s is restarting the server in 5 seconds", ply),
		Color = Color(200, 0, 0)
	})

	Log.Write("admin_restart", ply)

	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
	end)
end)

restart:SetCategory("Server Commands")
restart:SetDescription("Restarts the server on the current map")
restart:SetExecutionContext(console.Server)
restart:SetAccess(console.IsAdmin)

local function printMaps(maps)
	MsgC(Color(214, 172, 19), "Valid Maps:\n")
	for _, map in ipairs(maps) do
		MsgC(Color(229, 201, 98, 255), "\t", map, "\n")
	end
end

if CLIENT then
	netstream.Hook("MapList", function(data)
		printMaps(data.Maps)
	end)
end

local changeLevel = console.AddCommand("rpa_changelevel", function(ply, map)
	local maps = game.GetMapList()
	if not table.HasValue(maps, map) then
		if IsValid(ply) then
			netstream.Send(ply, "MapList", {
				Maps = maps
			})
		else
			printMaps(maps)
		end

		return
	end

	Chat.Send("GENERIC", {
		Text = console.FormatMessage("<giant>%s is changing the map to %s in 5 seconds", ply, map),
		Color = Color(200, 0, 0)
	})

	GAMEMODE:SetAutoMapOverride(map)
	Log.Write("admin_changelevel", ply, map)

	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end)

changeLevel:SetCategory("Server Commands")
changeLevel:SetDescription("Changes the current map from one to another")
changeLevel:SetExecutionContext(console.Server)
changeLevel:SetAccess(console.IsAdmin)

changeLevel:AddOptional(console.String())

local disableAI = console.AddCommand("rpa_ai_disable", function (ply, bool)
	Chat.Send("NOTICE", console.FormatMessage("%s has %s AI thinking", ply, bool and "disabled" or "enabled"), player.GetAdmins())

	Log.Write("admin_variable_set", ply, "ai_disable", bool and 1 or 0)

	GAMEMODE:SetAIDisabled(bool)
end)

disableAI:SetCategory("Server Commands")
disableAI:SetDescription("Enables/disables AI thinking")
disableAI:SetExecutionContext(console.Server)
disableAI:SetAccess(console.IsAdmin)

disableAI:AddParameter(console.Bool())

local ignoreAI = console.AddCommand("rpa_ai_notarget", function (ply, bool)
	Chat.Send("NOTICE", console.FormatMessage("%s has turned %s NPC's ignoring players", ply, bool and "on" or "off"), player.GetAdmins())

	Log.Write("admin_variable_set", ply, "ai_notarget", bool and 1 or 0)

	GAMEMODE:SetAINoTarget(bool)
end)

ignoreAI:SetCategory("Server Commands")
ignoreAI:SetDescription("Enables/disables NPC's ignoring players")
ignoreAI:SetExecutionContext(console.Server)
ignoreAI:SetAccess(console.IsAdmin)

ignoreAI:AddParameter(console.Bool())

local yell = console.AddCommand("rpa_yell", function(ply, message)
	Log.Write("admin_yell", ply, message)

	Chat.Send("ADMINYELL", {Name = console.RPName(ply), Text = message})
end)

yell:SetDescription("Sends a large text message to all players")
yell:SetExecutionContext(console.Server)
yell:SetAccess(console.IsAdmin)

yell:AddParameter(console.String())

-- local deadmin = console.AddCommand("rpa_deadmin", function(ply)
-- 	ply:SetTempUserGroup("user")

-- 	console.Feedback(ply, "NOTICE", "You've deadminned yourself")
-- 	Chat.Send("NOTICE", string.format("%s has deadminned themself", ply:Nick()), player.GetAdmins())
-- end)

-- deadmin:SetDescription("Removes yourself from the admin role")
-- deadmin:SetExecutionContext(console.Server)
-- deadmin:SetAccess(console.IsAdmin)

local oocDelay = console.AddCommand("rpa_oocdelay", function(ply, delay)
	GAMEMODE:SetOOCDelay(delay)

	Log.Write("admin_variable_set", ply, "OOCDelay", delay)

	Chat.Send("NOTICE", ply:Nick() .. " has set the OOC delay to " .. string.NiceTime(delay) .. ".")
end)

oocDelay:SetCategory("Server Commands")
oocDelay:SetDescription("Sets the global out-of-character chat delay")
oocDelay:SetExecutionContext(console.Server)
oocDelay:SetAccess(console.IsAdmin)

oocDelay:AddParameter(console.Duration({
	Max = "1 Hour"
}))

local oocDisable = console.AddCommand("rpa_oocdisable", function(ply)
	GAMEMODE:SetOOCDelay(-1)

	Log.Write("admin_variable_set", ply, "OOCDelay", -1)

	Chat.Send("NOTICE", ply:Nick() .. " has disabled OOC chat.")
end)

oocDisable:SetCategory("Server Commands")
oocDisable:SetDescription("Disables global out-of-character chat")
oocDisable:SetExecutionContext(console.Server)
oocDisable:SetAccess(console.IsAdmin)

if CLIENT then
	netstream.Hook("StopSound", function()
		RunConsoleCommand("stopsound")
	end)
end

local stopSound = console.AddCommand("rpa_stopsound", function(ply)
	Log.Write("admin_stopsound", ply)

	netstream.Broadcast("StopSound")
end)

stopSound:SetDescription("Forces all clients to run the stopsound command")
stopSound:SetExecutionContext(console.Server)
stopSound:SetAccess(console.IsAdmin)

local propInfo = console.AddCommand("rpa_propinfo", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if not IsValid(ent) then
		console.Feedback(ply, "NOTICE", "You're not looking at an entity!")

		return
	end

	console.Feedback(ply, "CONSOLE", table.concat(hook.Run("GetPropInfo", ply, ent), "\n"))
end)

propInfo:SetDescription("Get information about whatever prop you're looking at")
propInfo:SetExecutionContext(console.Server)
propInfo:SetAccess(console.IsAdmin)
propInfo:SetNoConsole()

local toggleSaved = console.AddCommand("rpa_togglesaved", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if IsValid(ent) and PermaProps.Whitelist[ent:GetClass()] then
		-- Context that gets passed to OnPermaPropChanged to write to PermaPropInfo
		Admin = ply

		local new = not ent:PermaProp()

		ent:SetPermaProp(new)
		Log.Write("admin_togglesaved",
			ply,
			ent.AttachedEntity and ent.AttachedEntity:GetModel() or ent:GetModel(),
			new)

		Admin = nil
	end
end)

toggleSaved:SetDescription("Toggles persistence on a prop or effect")
toggleSaved:SetExecutionContext(console.Server)
toggleSaved:SetAccess(console.IsAdmin)
toggleSaved:SetNoConsole()

local seeAll = console.AddCommand("rpa_seeall", function(ply)
	Settings.Set("SeeAll", not Settings.Get("SeeAll"))
end)

seeAll:SetDescription("Toggles SeeAll on or off")
seeAll:SetExecutionContext(console.ClientOnly)
seeAll:SetAccess(console.IsAdmin)
