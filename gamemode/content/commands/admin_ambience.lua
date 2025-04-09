if CLIENT then
	netstream.Hook("StopSound", function()
		RunConsoleCommand("stopsound")
	end)

	netstream.Hook("KillAmbience", function()
		Ambience.StopMusic()
		Ambience.StopEffect()
	end)

	netstream.Hook("PlayMusic", Ambience.PlayMusic)
	netstream.Hook("StopMusic", Ambience.StopMusic)

	netstream.Hook("PlayEffect", Ambience.PlayEffect)
	netstream.Hook("StopEffect", Ambience.StopEffect)
end

local priorityMapping = {
	["global"] = {
		Priority = AMBIENCE_GLOBAL,
		GetTargets = function()
			return player.GetAll()
		end
	},
	["local"] = {
		Priority = AMBIENCE_LOCAL,
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
stopSound:SetDescription("Forces all clients to run the stopsound command")
stopSound:SetExecutionContext(console.Server)
stopSound:SetAccess(console.IsAdmin)

local killAmbience = console.AddCommand("rpa_killambience", function(ply)
	Log.Write("admin_killambience", ply)

	netstream.Broadcast("KillAmbience")
end)

killAmbience:SetCategory("Ambience")
killAmbience:SetDescription("Stops all custom music and effects from playing, regardless of priority")
killAmbience:SetExecutionContext(console.Server)
killAmbience:SetAccess(console.IsAdmin)

local playMusic = console.AddCommand("rpa_playmusic", function(ply, level, path, volume)
	Log.Write("admin_playmusic", ply, level, path, volume)

	local config = priorityMapping[level]

	netstream.Send(config.GetTargets(ply), "PlayMusic", config.Priority, path, volume, ply:Nick())
end)

playMusic:SetCategory("Ambience")
playMusic:SetDescription("Plays a music track with the given priority")
playMusic:SetExecutionContext(console.Server)
playMusic:SetAccess(console.IsAdmin)
playMusic:SetNoConsole()

playMusic:AddParameter(console.String({
	validate.InList(table.GetKeys(priorityMapping))
}, "priority"))

playMusic:AddParameter(console.String({}, "path"))

playMusic:AddOptional(console.Number({
	Min = 0.01,
	Max = 2,
}, "volume"), 1)

local stopMusic = console.AddCommand("rpa_stopmusic", function(ply, level)
	local config = priorityMapping[level]

	netstream.Send(config.GetTargets(ply), "StopMusic", config.Priority)
end)

stopMusic:SetCategory("Ambience")
stopMusic:SetDescription("Stops a music track with the given priority from playing")
stopMusic:SetExecutionContext(console.Server)
stopMusic:SetAccess(console.IsAdmin)

stopMusic:AddParameter(console.String({
	validate.InList(table.GetKeys(priorityMapping))
}, "priority"))

local playEffect = console.AddCommand("rpa_playeffect", function(ply, level, path, volume)
	Log.Write("admin_playeffect", ply, level, path, volume)

	local config = priorityMapping[level]

	netstream.Send(config.GetTargets(ply), "PlayEffect", config.Priority, path, volume, ply:Nick())
end)

playEffect:SetCategory("Ambience")
playEffect:SetDescription("Plays an effect with the given priority")
playEffect:SetExecutionContext(console.Server)
playEffect:SetAccess(console.IsAdmin)
playEffect:SetNoConsole()

playEffect:AddParameter(console.String({
	validate.InList(table.GetKeys(priorityMapping))
}, "priority"))

playEffect:AddParameter(console.String({}, "path"))

playEffect:AddOptional(console.Number({
	Min = 0.01,
	Max = 2,
}, "volume"), 1)

local stopEffect = console.AddCommand("rpa_stopeffect", function(ply, level)
	local config = priorityMapping[level]

	netstream.Send(config.GetTargets(ply), "StopEffect", config.Priority)
end)

stopEffect:SetCategory("Ambience")
stopEffect:SetDescription("Stops an effect with the given priority from playing")
stopEffect:SetExecutionContext(console.Server)
stopEffect:SetAccess(console.IsAdmin)

stopEffect:AddParameter(console.String({
	validate.InList(table.GetKeys(priorityMapping))
}, "priority"))
