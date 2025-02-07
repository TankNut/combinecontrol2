local restart = console.AddCommand("rpa_restart", function(ply)
	GAMEMODE:WriteLog("admin_restart", {Admin = GAMEMODE:LogPlayer(ply)})
	Chat.Send("GENERIC", {
		Text = console.FormatMessage("<giant>%s is restarting the server in 5 seconds", ply),
		Color = Color(200, 0, 0)
	})

	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
	end)
end)

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

	GAMEMODE:WriteLog("admin_changelevel", {Admin = GAMEMODE:LogPlayer(ply), Map = map})
	Chat.Send("GENERIC", {
		Text = console.FormatMessage("<giant>%s is changing the map to %s in 5 seconds", ply, map),
		Color = Color(200, 0, 0)
	})

	file.Write("cc_maps/" .. game.GetPort() .. ".txt", map)
	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end)

changeLevel:SetDescription("Changes the current map from one to another")
changeLevel:SetExecutionContext(console.Server)
changeLevel:SetAccess(console.IsAdmin)

changeLevel:AddOptional(console.String())

local aiDisabled = console.AddCommand("rpa_aidisabled", function (ply, bool)
	Chat.Send("NOTICE", console.FormatMessage("%s has %s AI thinking", ply, bool and "disabled" or "enabled"), player.GetAdmins())

	RunConsoleCommand("ai_disabled", bool and 1 or 0)
end)

aiDisabled:SetDescription("Updates the AI Disabled server console variable")
aiDisabled:SetExecutionContext(console.Server)
aiDisabled:SetAccess(console.IsAdmin)

aiDisabled:AddParameter(console.Bool())

local yell = console.AddCommand("rpa_yell", function(ply, message)
	Chat.Send("ADMINYELL", {Name = console.RPName(ply), Text = message})
end)

yell:SetDescription("Announces a large-text message to all players")
yell:SetExecutionContext(console.Server)
yell:SetAccess(console.IsAdmin)

yell:AddParameter(console.String())

local deadmin = console.AddCommand("rpa_deadmin", function(ply)
	ply:SetUserGroup("user", true)

	console.Feedback(ply, "NOTICE", "You've deadminned yourself")
	Chat.Send("NOTICE", string.format("%s has deadminned themself", ply:Nick()), player.GetAdmins())
end)

deadmin:SetDescription("Removes yourself from the admin role")
deadmin:SetExecutionContext(console.Server)
deadmin:SetAccess(console.IsAdmin)

local oocDelay = console.AddCommand("rpa_oocdelay", function(ply, delay)
	GAMEMODE:SetOOCDelay(delay)
	GAMEMODE:LogAdmin("[V] " .. ply:Nick() .. " set variable \"rpa_oocdelay\" to \"" .. tonumber(delay) .. "\".", ply)

	if delay < 0 then
		Chat.Send("NOTICE", ply:Nick() .. " has disabled OOC chat.")
	else
		Chat.Send("NOTICE", ply:Nick() .. " has set the OOC delay to " .. string.NiceTime(delay) .. ".")
	end
end)

oocDelay:SetDescription("Sets the global out-of-character chat delay, -1 to disable")
oocDelay:SetExecutionContext(console.Server)
oocDelay:SetAccess(console.IsAdmin)

oocDelay:AddParameter(console.Number({
	validate.Min(-1),
	validate.Max(86400)
}))

if CLIENT then
	netstream.Hook("StopSound", function()
		RunConsoleCommand("stopsound")
	end)
end

local stopSound = console.AddCommand("rpa_stopsound", function(ply)
	netstream.Broadcast("StopSound")
end)

stopSound:SetDescription("Forces all clients to run the stopsound command")
stopSound:SetExecutionContext(console.Server)
stopSound:SetAccess(console.IsAdmin)

local propInfo = console.AddCommand("rpa_propinfo", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if not IsValid(ent) then
		console.Feedback(ply, "NOTICE", "You're not looking at a prop!")

		return
	end

	local info = hook.Run("GetPropInfo", ply, ent)

	for _, line in ipairs(info) do
		console.Feedback(ply, "NOTICE", (string.Left(line, 2) == "--" and "" or "  ") .. line)
	end
end)

propInfo:SetDescription("Get information about whatever prop you're looking at")
propInfo:SetExecutionContext(console.Server)
propInfo:SetAccess(console.IsAdmin)
propInfo:SetNoConsole()

local seeAll = console.AddCommand("rpa_seeall", function(ply)
	Settings.Set("SeeAll", not Settings.Get("SeeAll"))
end)

seeAll:SetDescription("Toggles SeeAll on or off")
seeAll:SetExecutionContext(console.ClientOnly)
seeAll:SetAccess(console.IsAdmin)
