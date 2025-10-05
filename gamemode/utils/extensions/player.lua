local PLAYER = FindMetaTable("Player")

if SERVER then
	function PLAYER:ScaleMaxArmor(newMax)
		local ratio = self:Armor() / self:GetMaxArmor()
		local newValue = math.Round(ratio * newMax)

		self:SetMaxArmor(newMax)
		self:SetArmor(newValue)
	end
end

local steamCache, steam64Cache = {}, {}

if not PLAYER._SteamID then
	PLAYER._SteamID = PLAYER.SteamID
end

function PLAYER:SteamID()
	if not steamCache[self] then
		steamCache[self] = PLAYER._SteamID(self)
	end

	return steamCache[self]
end

if not PLAYER._SteamID64 then
	PLAYER._SteamID64 = PLAYER.SteamID64
end

function PLAYER:SteamID64()
	if not steam64Cache[self] then
		steam64Cache[self] = PLAYER._SteamID64(self)
	end

	return steam64Cache[self]
end

if SERVER then
	hook.Add("PlayerDisconnected", "player", function(ply)
		steamCache[ply] = nil
		steam64Cache[ply] = nil
	end)
end

function PLAYER:IsInNoClip()
	return self:IsEFlagSet(EFL_NOCLIP_ACTIVE)
end

function PLAYER:WithinInteractRange(target, range)
	range = range or MAX_USE_DISTANCE

	local eye = self:EyePos()
	local pos = target

	if isentity(target) then
		pos = target:NearestPoint(eye)
	end

	return eye:Distance(pos) <= range
end

function PLAYER:GetCrouchState()
	if not self:OnGround() then
		return 0
	end

	local offset = self:GetViewOffset().z
	local crouchOffset = self:GetViewOffsetDucked().z

	if offset == crouchOffset then
		return 0
	end

	return math.Clamp(math.TimeFraction(offset, crouchOffset, self:GetCurrentViewOffset().z), 0, 1)
end

function PLAYER:IsHoldingWeapon(class)
	local weapon = self:GetActiveWeapon()

	return IsValid(weapon) and weapon:IsType(class)
end

function PLAYER:FindOpenSpace(origin)
	local mins, maxs = self:GetHull()
	local scale = self:GetModelScale()

	mins:Mul(scale)
	maxs:Mul(scale)

	local result = {}
	local trace = {
		start = origin + Vector(0, 0, maxs.z * 0.5),
		endpos = origin,
		mins = mins,
		maxs = maxs,
		filter = self,
		mask = MASK_PLAYERSOLID,
		output = result
	}

	util.TraceHull(trace)

	if not result.StartSolid then
		return result.HitPos
	end

	local dist = maxs.x - mins.x

	-- Potential improvements, some method for making sure you don't end up behind a wall/outside?
	for i = 1, 25 do
		local ang = math.rad(math.random(0, 359))
		local radius = math.Rand(dist * 2, dist * 5)

		local x = math.cos(ang) * radius
		local y = math.sin(ang) * radius

		trace.start = origin + Vector(x, y, maxs.z * 0.5)
		trace.endpos = origin + Vector(x, y, maxs.z * -0.2)

		util.TraceHull(trace)

		if not result.StartSolid and result.Fraction != 1 then
			return result.HitPos
		end
	end

	return origin
end

function player.GetAdmins()
	local tab = {}

	for _, ply in player.Iterator() do
		if ply:IsAdmin() then
			table.insert(tab, ply)
		end
	end

	return tab
end

do
	local playerCache = {}

	local function fill(ply)
		playerCache[ply:SteamID()] = ply
		playerCache[ply:SteamID64()] = ply
		-- playerCache[ply:UniqueID()] = ply -- No don't
	end

	for _, ply in player.Iterator() do
		fill(ply)
	end

	hook.Add("OnEntityCreated", "player", function(ent)
		if IsValid(ent) and ent:IsPlayer() then
			fill(ent)
		end
	end)

	function player.GetBySteamID(id)
		local ply = playerCache[string.upper(id)]

		return IsValid(ply) and ply or false
	end

	function player.GetBySteamID64(id)
		local ply = playerCache[tostring(id)]

		return IsValid(ply) and ply or false
	end
end
