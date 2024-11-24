local uptime = console.AddCommand("rp_uptime", function(ply)
	console.PrintMessage(ply, "Server Uptime: %s", string.NiceTime(CurTime()))
end)

uptime:SetDescription("Tells you how long the server has been running the current map for")
uptime:SetExecutionContext(console.Shared)
