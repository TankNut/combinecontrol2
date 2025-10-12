local cSay = console.AddCommand("csay", function(_, message)
	Chat.Send("NOTICE", message)
end)

cSay:SetDescription("Send a message to all clients from the server console")
cSay:SetExecutionContext(console.ServerConsole)

cSay:AddParameter(console.String())





local aSay = console.AddCommand("asay", function(_, message)
	Chat.Send("Admin", {Name = "CONSOLE", Text = message}, player.GetAdmins())
end)

aSay:SetDescription("Send a message to admins from the server console")
aSay:SetExecutionContext(console.ServerConsole)

aSay:AddParameter(console.String())
