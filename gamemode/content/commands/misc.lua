local uptime = console.AddCommand("rp_uptime", function(ply)
	console.PrintMessage(ply, "Server Uptime: %s", string.NiceTime(CurTime()))
end)

uptime:SetDescription("Tells you how long the server has been running the current map for")
uptime:SetExecutionContext(console.Shared)

local whatIsThis = console.AddCommand("rp_whatisthis", function(ply)
	local ent = ply:GetEyeTrace().Entity

	if not ent or not (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_effect") then
		return
	end

	local model = ent.AttachedEntity and ent.AttachedEntity:GetModel() or ent:GetModel()

	console.PrintMessage(ply, "Prop Model: %s", model)
end)

whatIsThis:SetDescription("Tells you the path of the current model you're looking at")
whatIsThis:SetExecutionContext(console.ClientOnly)

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

local openMotd = console.AddCommand("rp_motd", function()
	GUI.Open("MOTD")
end)

openMotd:SetDescription("Opens the server's MOTD / update log")
openMotd:SetExecutionContext(console.ClientOnly)
