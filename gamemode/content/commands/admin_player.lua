local setPhysTrust = console.AddCommand("rpa_setphystrust", function (ply, target, bool)
	target:SetPhysTrust(bool and PHYSTRUST_ENABLED or PHYSTRUST_BANNED)
	target:UpdateLoadout()

	GAMEMODE:LogAdmin("[S] " .. ply:Nick() .. " changed player " .. target:CharacterName() .. "'s phystrust to " .. tostring(bool), ply)

	console.Feedback(ply, "NOTICE", "You %s %s physics gun trust", bool and "gave" or "removed", target)
	console.Feedback(target, "NOTICE", "%s has %s physics gun trust", ply, bool and "given you" or "taken your")
end)

setPhysTrust:SetDescription("Sets a player's physics gun access")
setPhysTrust:SetExecutionContext(console.Server)
setPhysTrust:SetAccess(console.IsAdmin)

setPhysTrust:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

setPhysTrust:AddParameter(console.Bool())

local setPropTrust = console.AddCommand("rpa_setproptrust", function (ply, target, bool)
	target:SetPropTrust(bool and PROPTRUST_ENABLED or PROPTRUST_BANNED)
	target:UpdateLoadout()

	GAMEMODE:LogAdmin("[S] " .. ply:Nick() .. " changed player " .. target:CharacterName() .. "'s proptrust to " .. tostring(bool), ply)

	console.Feedback(ply, "NOTICE", "You %s %s prop spawning trust", bool and "gave" or "removed", target)
	console.Feedback(target, "NOTICE", "%s has %s prop spawning trust", ply, bool and "given you" or "taken your")
end)

setPropTrust:SetDescription("Sets a player's prop spawning access")
setPropTrust:SetExecutionContext(console.Server)
setPropTrust:SetAccess(console.IsAdmin)

setPropTrust:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

setPropTrust:AddParameter(console.Bool())

local toolTrustMapping = {
	banned = TOOLTRUST_BANNED,
	basic = TOOLTRUST_BASIC,
	advanced = TOOLTRUST_ADVANCED
}

local setToolTrust = console.AddCommand("rpa_settooltrust", function (ply, target, trust)
	local toolTrustLevel = toolTrustMapping[trust]

	target:SetToolTrust(toolTrustLevel)
	target:UpdateLoadout()

	GAMEMODE:LogAdmin("[S] " .. ply:Nick() .. " changed player " .. target:CharacterName() .. "'s tooltrust to " .. tostring(trust), ply)

	console.Feedback(ply, "NOTICE", "You've set %s's tool trust to %s", target, trust)
	console.Feedback(target, "NOTICE", "%s has set your tool trust to %s", ply, trust)
end)

setToolTrust:SetDescription("Sets a player's toolgun access")
setToolTrust:SetExecutionContext(console.Server)
setToolTrust:SetAccess(console.IsAdmin)

setToolTrust:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

setToolTrust:AddParameter(console.String({
	validate.InList(table.GetKeys(toolTrustMapping))
}))

local oocMute = console.AddCommand("rpa_oocmute", function (ply, target, bool)
	target:SetOOCMuted(bool and 1 or 0)

	GAMEMODE:LogAdmin("[S] " .. ply:Nick() .. " changed player " .. target:CharacterName() .. "'s ooc mute to " .. tostring(bool), ply)

	console.Feedback(ply, "NOTICE", "You %s %s from OOC chat", bool and "muted" or "unmuted", target)
	console.Feedback(target, "NOTICE", "%s has %s you from OOC chat", ply, bool and "muted" or "unmuted")
end)

oocMute:SetDescription("Mute or unmutes a player from OOC chat")
oocMute:SetExecutionContext(console.Server)
oocMute:SetAccess(console.IsAdmin)

oocMute:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = true,
	NoSelfTarget = false
}))

oocMute:AddParameter(console.Bool())
