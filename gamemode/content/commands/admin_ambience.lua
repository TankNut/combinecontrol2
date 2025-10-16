if CLIENT then
	netstream.Hook("StopSound", function()
		RunConsoleCommand("stopsound")
	end)

	netstream.Hook("PlayMusic", Ambience.PlayMusic)
	netstream.Hook("StopMusic", Ambience.StopMusic)

	netstream.Hook("PlayEffect", Ambience.PlayEffect)
	netstream.Hook("StopEffect", Ambience.StopEffect)
end

local areaMapping = {
	["global"] = {
		Area = AMBIENCE_GLOBAL,
		GetTargets = function()
			return player.GetAll()
		end
	},
	["local"] = {
		Area = AMBIENCE_LOCAL,
		GetTargets = function(ply)
			local targets = {ply}

			-- Using the same method as local-event, currently.
			for _, v in player.Iterator() do
				if v:TestPVS(ply) then
					table.insert(targets, v)
				end
			end

			return targets
		end
	}
}






local stopSound = console.AddCommand("rpa_stopsound", function(ply)
	Log.Write("admin_stopsound", ply)

	netstream.Broadcast("StopSound")
end)

stopSound:SetCategory("Ambience")
stopSound:SetDescription("Stops any sounds that are playing on the server")
stopSound:SetExecutionContext(console.Server)
stopSound:SetAccess(console.IsAdmin)





local playMusic = console.AddCommand("rpa_music_play", function(ply, level, path, volume)
	Log.Write("admin_playmusic", ply, level, path, volume)

	local mapping = areaMapping[level]

	netstream.Send(mapping.GetTargets(ply), "PlayMusic", mapping.Area, path, volume, ply:Nick())
end)

playMusic:SetCategory("Ambience")
playMusic:SetDescription("Plays a music track with the given area")
playMusic:SetExecutionContext(console.Server)
playMusic:SetAccess(console.IsAdmin)
playMusic:SetNoConsole()

playMusic:AddParameter(console.String({
	validate.InList(table.GetKeys(areaMapping))
}, "area"))

playMusic:AddParameter(console.String({}, "path"))
playMusic:AddOptional(console.Number({validate.Min(0.01), validate.Max(2)}, "volume"), 1)





local stopMusic = console.AddCommand("rpa_music_stop", function(ply, level)
	local mapping = areaMapping[level]

	netstream.Send(mapping.GetTargets(ply), "StopMusic", mapping.Area)
end)

stopMusic:SetCategory("Ambience")
stopMusic:SetDescription("Stops a music track with the given area from playing")
stopMusic:SetExecutionContext(console.Server)
stopMusic:SetAccess(console.IsAdmin)

stopMusic:AddParameter(console.String({
	validate.InList(table.GetKeys(areaMapping))
}, "area"))





local playEffect = console.AddCommand("rpa_effect_play", function(ply, level, path, volume)
	Log.Write("admin_playeffect", ply, level, path, volume)

	local config = areaMapping[level]

	netstream.Send(config.GetTargets(ply), "PlayEffect", config.Area, path, volume, ply:Nick())
end)

playEffect:SetCategory("Ambience")
playEffect:SetDescription("Plays an effect with the given area")
playEffect:SetExecutionContext(console.Server)
playEffect:SetAccess(console.IsAdmin)
playEffect:SetNoConsole()

playEffect:AddParameter(console.String({
	validate.InList(table.GetKeys(areaMapping))
}, "area"))

playEffect:AddParameter(console.String({}, "path"))
playEffect:AddOptional(console.Number({validate.Min(0.01), validate.Max(2)}, "volume"), 1)





local stopEffect = console.AddCommand("rpa_effect_stop", function(ply, level)
	local config = areaMapping[level]

	netstream.Send(config.GetTargets(ply), "StopEffect", config.Area)
end)

stopEffect:SetCategory("Ambience")
stopEffect:SetDescription("Stops an effect with the given area from playing")
stopEffect:SetExecutionContext(console.Server)
stopEffect:SetAccess(console.IsAdmin)

stopEffect:AddParameter(console.String({
	validate.InList(table.GetKeys(areaMapping))
}, "area"))
