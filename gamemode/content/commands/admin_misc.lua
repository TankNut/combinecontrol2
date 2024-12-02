local restart = console.AddCommand("rpa_restart", function(ply)
	GAMEMODE:WriteLog("admin_restart", {Admin = GAMEMODE:LogPlayer(ply)})
	GAMEMODE:SendChat(nil, player.GetAll(), "ERRORBIG", console.FormatMessage("%s is restarting the server in 5 seconds", ply))

	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
	end)
end)

restart:SetDescription("Restarts the server on the current map")
restart:SetExecutionContext(console.Server)
restart:SetAccess(console.IsAdmin)

if CLIENT then
	netstream.Hook("MapList", function(data)
		MsgC(Color(214, 172, 19), "Valid Maps:\n")

		for _, v in pairs(data.Maps) do
			MsgC(Color(229, 201, 98, 255), "\t", v, "\n")
		end
	end)
end

local changeLevel = console.AddCommand("rpa_changelevel", function(ply, map)
	if not table.HasValue(game.GetMapList(), map) then
		netstream.Send(ply, "MapList", {
			Maps = game.GetMapList()
		})

		return
	end

	GAMEMODE:WriteLog("admin_changelevel", {Admin = GAMEMODE:LogPlayer(ply), Map = map})
	GAMEMODE:SendChat(nil, player.GetAll(), "ERRORBIG", ply:Nick() .. " is changing the map to " .. map .. " in 5 seconds")

	file.Write("cc_maps/" .. game.GetPort() .. ".txt", map)
	timer.Simple(5, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end)

changeLevel:SetDescription("Changes the current map from one to another")
changeLevel:SetExecutionContext(console.Server)
changeLevel:SetAccess(console.IsAdmin)

changeLevel:AddOptional(console.String())
