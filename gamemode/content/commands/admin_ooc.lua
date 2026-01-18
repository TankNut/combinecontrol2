local setDelay = console.AddCommand("rpa_ooc_delay", function(ply, delay)
	GAMEMODE:SetOOCDelay(delay)

	Log.Write("admin_variable_set", ply, "OOCDelay", delay)

	Chat.Send("NOTICE", console.FormatMessage("%s has set the OOC delay to %s", ply, string.NiceTime(delay)))
end)

setDelay:SetCategory("OOC Commands")
setDelay:SetDescription("Sets the global out-of-character chat delay")
setDelay:SetExecutionContext(console.Server)
setDelay:SetAccess(console.IsAdmin)

setDelay:AddParameter(console.Duration({Max = "1 Hour"}))





local disable = console.AddCommand("rpa_ooc_disable", function(ply)
	GAMEMODE:SetOOCDelay(-1)

	Log.Write("admin_variable_set", ply, "OOCDelay", -1)

	Chat.Send("NOTICE", console.FormatMessage("%s has disabled OOC chat", ply))
end)

disable:SetCategory("OOC Commands")
disable:SetDescription("Disables global out-of-character chat")
disable:SetExecutionContext(console.Server)
disable:SetAccess(console.IsAdmin)





local oocMute = console.AddCommand("rpa_ooc_mute", function(ply, target, bool)
	local new

	if bool == nil then
		new = not target:OOCMuted()
	else
		new = bool
	end

	target:SetOOCMuted(new)

	console.Feedback(ply, "NOTICE", "You %s %s from OOC chat", new and "muted" or "unmuted", target)
	console.Feedback(target, "NOTICE", "%s has %s you from OOC chat", ply, new and "muted" or "unmuted")

	Log.Write("admin_mute", ply, target, new)
end)

oocMute:SetCategory("OOC Commands")
oocMute:SetChatAlias("mute")
oocMute:SetDescription("Mutes or unmutes a player from OOC chat")
oocMute:SetExecutionContext(console.Server)
oocMute:SetAccess(console.IsAdmin)

oocMute:AddParameter(console.Player({NoAdmins = true}))
oocMute:AddOptional(console.Bool())
