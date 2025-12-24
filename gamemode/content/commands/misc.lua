local uptime = console.AddCommand("rp_uptime", function(ply)
	console.PrintMessage(ply, "Server Uptime: %s", string.NiceTime(CurTime()))
end)

uptime:SetDescription("Tells you how long the server has been running the current map for")
uptime:SetExecutionContext(console.Shared)





local what = console.AddCommand("whatisthis", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if not ent or not (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_effect") then
		return
	end

	local model = ent.AttachedEntity and ent.AttachedEntity:GetModel() or ent:GetModel()

	console.PrintMessage(ply, "Model Path: %s", model)
end)

what:SetDescription("Tells you the path of the model you're looking at")
what:SetExecutionContext(console.ClientOnly)





local toggleHUD = console.AddCommand("rp_togglehud", function()
	Settings.Set("Hud", not Settings.Get("Hud"))
end)

toggleHUD:SetDescription("Toggles whether your HUD is enabled or not")
toggleHUD:SetExecutionContext(console.ClientOnly)





local toggleThirdperson = console.AddCommand("rp_thirdperson", function(ply)
	Settings.Set("Thirdperson", not Settings.Get("Thirdperson"))
end)

toggleThirdperson:SetDescription("Toggles your thirdperson state")
toggleThirdperson:SetExecutionContext(console.ClientOnly)





local roll = console.AddCommand("rp_roll", function(ply, diceFormat)
	local num, sides, sign, mod

	num, sides, sign, mod = string.match(diceFormat, "^ *(%d+)d(%d+) *([%+%-]?) *(%d*) *$")
	num, sides, mod = tonumber(num), tonumber(sides), tonumber(mod)

	if not (num and sides) then
		console.Feedback(ply, "ERROR", "Missing number of dice and number of sides arguments.")

		return
	end

	num = math.Clamp(num, 1, 10)
	sides = math.Clamp(sides, 2, 100)

	local results, total = {}, 0

	for i = 1, num do
		local r = math.random(sides)
		total = total + r
		results[i] = r
	end

	local mult, output
	local str = table.concat(results, " + ")

	if #sign > 0 and mode != 0 then
		mult = tonumber(sign .. mod)
		total = total + mult
		output = string.format("%s rolled %id%i%s%i: (%s) %s %i = %i", ply:VisibleRPName(), num, sides, sign, mod, str, sign, mod, total)
	else
		output = string.format("%s rolled %id%i: (%s) = %i", ply:VisibleRPName(), num, sides, str, total)
	end

	ply:VisibleMessage("NOTICE", output)
end)

roll:SetChatAlias("roll")
roll:SetDescription("Rolls dice, command format is 'NdX+m' where N = # of dice, X = # of sides on dice and m = optional modifier. e.g. rp_roll 2d20-4 will roll two d20's with a -4 modifier applied")
roll:SetExecutionContext(console.Server)
roll:SetNoConsole()

roll:AddParameter(console.String())





local stopEffect = console.AddCommand("rp_effect_stop", function()
	Ambience.StopEffect()
end)

stopEffect:SetDescription("Halts playback of the current ambient-effect file.")
stopEffect:SetExecutionContext(console.ClientOnly)





local stopMusic = console.AddCommand("rp_music_stop", function()
	Ambience.StopMusic()
end)

stopMusic:SetDescription("Halts playback of the current ambient-music file.")
stopMusic:SetExecutionContext(console.ClientOnly)
