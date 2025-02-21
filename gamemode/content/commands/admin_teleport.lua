local GoodTraceVectors = {
	Vector(40, 0, 0),
	Vector(-40, 0, 0),
	Vector(0, 40, 0),
	Vector(0, -40, 0),
	Vector(0, 0, 40)
}

local function FindTeleportPos(ply)
	local trace = {}

	trace.start = ply:GetShootPos()
	trace.endpos = trace.start + ply:GetAimVector() * 50
	trace.mins = Vector(-16, -16, 0)
	trace.maxs = Vector(16, 16, 72)
	trace.filter = ply

	local tr = util.TraceHull(trace)

	if not tr.Hit then
		return tr.HitPos
	end

	local pos = ply:GetPos()

	for _, v in pairs(GoodTraceVectors) do
		trace = {}

		trace.start = ply:GetPos()
		trace.endpos = trace.start + v
		trace.mins = Vector(-16, -16, 0)
		trace.maxs = Vector(16, 16, 72)
		trace.filter = ply

		tr = util.TraceHull(trace)

		if tr.Fraction == 1.0 then
			pos = ply:GetPos() + v
			break
		end
	end

	return pos
end

local goTo = console.AddCommand("rpa_goto", function(ply, target)
	ply:SetPos(FindTeleportPos(target))
end)

goTo:SetCategory("Teleport Commands")
goTo:SetDescription("Teleports yourself to another player on the server")
goTo:SetExecutionContext(console.Server)
goTo:SetAccess(console.IsAdmin)
goTo:SetNoConsole()

goTo:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = true
}))

local bring = console.AddCommand("rpa_bring", function(ply, target)
	target:SetPos(FindTeleportPos(ply))
end)

bring:SetCategory("Teleport Commands")
bring:SetDescription("Teleports another player on the server to yourself")
bring:SetExecutionContext(console.Server)
bring:SetAccess(console.IsAdmin)
bring:SetNoConsole()

bring:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = true
}))

local send = console.AddCommand("rpa_send", function(ply, from, to)
	from:SetPos(FindTeleportPos(to))
end)

send:SetCategory("Teleport Commands")
send:SetDescription("Teleports one player to another player on the server")
send:SetExecutionContext(console.Server)
send:SetAccess(console.IsAdmin)

send:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = true
}))

send:AddParameter(console.Player({
	SingleTarget = true,
	CheckImmunity = false,
	NoSelfTarget = true
}))
