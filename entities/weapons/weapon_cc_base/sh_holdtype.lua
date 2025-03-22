AddCSLuaFile()

local baseHoldTypes = {
	["pistol"]   = ACT_HL2MP_IDLE_PISTOL,
	["smg"]      = ACT_HL2MP_IDLE_SMG1,
	["grenade"]  = ACT_HL2MP_IDLE_GRENADE,
	["ar2"]      = ACT_HL2MP_IDLE_AR2,
	["shotgun"]  = ACT_HL2MP_IDLE_SHOTGUN,
	["rpg"]      = ACT_HL2MP_IDLE_RPG,
	["physgun"]  = ACT_HL2MP_IDLE_PHYSGUN,
	["crossbow"] = ACT_HL2MP_IDLE_CROSSBOW,
	["melee"]    = ACT_HL2MP_IDLE_MELEE,
	["slam"]     = ACT_HL2MP_IDLE_SLAM,
	["normal"]   = ACT_HL2MP_IDLE,
	["fist"]     = ACT_HL2MP_IDLE_FIST,
	["melee2"]   = ACT_HL2MP_IDLE_MELEE2,
	["passive"]  = ACT_HL2MP_IDLE_PASSIVE,
	["knife"]    = ACT_HL2MP_IDLE_KNIFE,
	["duel"]     = ACT_HL2MP_IDLE_DUEL,
	["camera"]   = ACT_HL2MP_IDLE_CAMERA,
	["magic"]    = ACT_HL2MP_IDLE_MAGIC,
	["revolver"] = ACT_HL2MP_IDLE_REVOLVER
}

local holdTypes = {}

for k, v in pairs(baseHoldTypes) do
	holdTypes[k] = {
		[ACT_MP_STAND_IDLE]                = v,
		[ACT_MP_WALK]                      = v + 1,
		[ACT_MP_RUN]                       = v + 2,
		[ACT_MP_CROUCH_IDLE]               = v + 3,
		[ACT_MP_CROUCHWALK]                = v + 4,
		[ACT_MP_ATTACK_STAND_PRIMARYFIRE]  = v + 5,
		[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = v + 5,
		[ACT_MP_RELOAD_STAND]              = v + 6,
		[ACT_MP_RELOAD_CROUCH]             = v + 6,
		[ACT_MP_JUMP]                      = v + 7,
		[ACT_RANGE_ATTACK1]                = v + 8,
		[ACT_MP_SWIM]                      = v + 9
	}
end

holdTypes.normal[ACT_MP_JUMP] = ACT_HL2MP_JUMP_SLAM

holdTypes.passive[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH
holdTypes.passive[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH

SWEP.HoldTypes = holdTypes

function SWEP:SetWeaponHoldType(set)
	self.ActivityTranslate = holdTypes[set] or holdTypes.normal
	self:SetupWeaponHoldTypeForAI(set)
end

function SWEP:TranslateActivity(act)
	if self:GetOwner():IsNPC() then
		return self.ActivityTranslateAI[act] or -1
	end

	return self.ActivityTranslate[act] or -1
end

function SWEP:GetLoweredHoldType()
	return self.Settings.LowerHoldType
end

function SWEP:GetBaseHoldType()
	return self.Settings.BaseHoldType
end

function SWEP:UpdateHoldType()
	local old = self:GetHoldType()
	local holdType = self:GetBaseHoldType()

	if self:ShouldLower() or self:GetHolstered() then
		holdType = self:GetLoweredHoldType()
	end

	if holdType != old then
		self:SetHoldType(holdType)
	end
end
