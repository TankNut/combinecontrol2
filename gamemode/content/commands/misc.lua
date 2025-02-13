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

	console.PrintMessage(ply, "Prop Model: %s", model)
end)

what:SetDescription("Tells you the path of the current model you're looking at")
what:SetExecutionContext(console.ClientOnly)

local toggleHUD = console.AddCommand("rp_togglehud", function()
	Settings.Set("HUD", not Settings.Get("HUD"))
end)

toggleHUD:SetDescription("Toggles your HUD between active and disabled")
toggleHUD:SetExecutionContext(console.ClientOnly)

local toggleThirdperson = console.AddCommand("rp_thirdperson", function(ply)
	Settings.Set("Thirdperson", not Settings.Get("Thirdperson"))
end)

toggleThirdperson:SetDescription("Toggles your thirdperson between active and disabled")
toggleThirdperson:SetExecutionContext(console.ClientOnly)
