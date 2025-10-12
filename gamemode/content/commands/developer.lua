local editGlobal = console.AddCommand("dev_maplua_global", function(ply)
	local lua = GAMEMODE:GlobalLua()

	if lua == "" then
		lua = "-- No global lua found"
	end

	ply:OpenGUI("DevEditor", lua)
end)

editGlobal:SetCategory("Developer Commands")
editGlobal:SetDescription("Accesses the global lua console")
editGlobal:SetExecutionContext(console.Server)
editGlobal:SetAccess(console.IsDeveloper)
editGlobal:SetNoConsole()





local editMap = console.AddCommand("dev_maplua", function(ply, map)
	if not map or map == "" then
		map = game.GetMap()

		local lua = GAMEMODE:MapLua()

		if lua == "" then
			lua = "-- No map lua found for " .. map
		end

		ply:OpenGUI("DevEditor", lua, map)

		return
	end

	local data = GAMEMODE.Database:Query("SELECT * FROM `rp_globals` WHERE `Map` = :map AND `Key` = 'MapLua'", {
		map = map
	})[1]

	if data then
		ply:OpenGUI("DevEditor", sfs.decode(data.Value), map)
	else
		ply:OpenGUI("DevEditor", "-- No map lua found for " .. map, map)
	end
end)

editMap:SetCategory("Developer Commands")
editMap:SetDescription("Accesses a specific map's lua console")
editMap:SetExecutionContext(console.Server)
editMap:SetAccess(console.IsDeveloper)
editMap:SetNoConsole()

editMap:AddOptional(console.String(), nil, "current map")
