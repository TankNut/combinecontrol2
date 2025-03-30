module("Npc", package.seeall)

local PLAYER = FindMetaTable("Player")

function PLAYER:GetClassification()
	return self.Classification or CLASSIFY_NEUTRAL
end

function PLAYER:IsLoneWolf()
	return (self.LoneWolfCounter or 0) >= Config.Get("LoneWolfCounter")
end

function PLAYER:IsArmed()
	local weapon = self:GetActiveWeapon()

	return IsValid(weapon) and weapon.Dangerous
end

function GM:GetPlayerClassification(ply)
	if ply:IsLoneWolf() then
		return CLASSIFY_LONEWOLF
	end

	if ply:IsArmed() then
		return CLASSIFY_ARMED
	end

	return CLASSIFY_NEUTRAL
end

local classMap = {
	[CLASS_COMBINE]         = "combine",
	[CLASS_COMBINE_GUNSHIP] = "combine",
	[CLASS_COMBINE_HUNTER]  = "combine",
	[CLASS_METROPOLICE]     = "combine",
	[CLASS_STALKER]         = "combine",
	[CLASS_PROTOSNIPER]     = "combine",

	-- NPC's that need to be angry all the time
	[CLASS_MANHACK]  = "combine_angry",
	[CLASS_SCANNER]  = "combine_angry", -- Otherwise they don't take pictures
	[CLASS_MILITARY] = "combine_angry", -- Combine cameras

	[CLASS_VORTIGAUNT]        = "rebel",
	[CLASS_PLAYER_ALLY]       = "rebel",
	[CLASS_PLAYER_ALLY_VITAL] = "rebel",
	[CLASS_HACKED_ROLLERMINE] = "rebel",

	[CLASS_ANTLION] = "antlion",
	[CLASS_ZOMBIE]  = "zombie"
}

-- Good luck, enemies might stop fighting just to kill you
local function loneWolf() return D_HT, 5 end

local classifications = {
	["combine"] = {
		[CLASSIFY_NEUTRAL]  = D_NU,
		[CLASSIFY_ARMED]    = D_HT,
		[CLASSIFY_LONEWOLF] = loneWolf,
		[CLASSIFY_COMBINE]  = D_LI,
		[CLASSIFY_ANTLION]  = D_HT,
		[CLASSIFY_ZOMBIE]   = D_HT,
	},

	["combine_angry"] = {
		[CLASSIFY_NEUTRAL]  = D_NU,
		[CLASSIFY_ARMED]    = D_HT,
		[CLASSIFY_LONEWOLF] = loneWolf,
		[CLASSIFY_COMBINE]  = D_LI,
		[CLASSIFY_ANTLION]  = D_HT,
		[CLASSIFY_ZOMBIE]   = D_HT,
	},

	["rebel"] = { -- Rebels are neutral to humans and hate everyone else #xenophobia
		[CLASSIFY_NEUTRAL]  = D_NU,
		[CLASSIFY_ARMED]    = D_LI,
		[CLASSIFY_LONEWOLF] = loneWolf,
		[CLASSIFY_COMBINE]  = D_HT,
		[CLASSIFY_ANTLION]  = D_HT,
		[CLASSIFY_ZOMBIE]   = D_HT,
	},

	["antlion"] = { -- Antlions like their own kind
		[CLASSIFY_NEUTRAL]  = D_HT,
		[CLASSIFY_ARMED]    = D_HT,
		[CLASSIFY_LONEWOLF] = loneWolf,
		[CLASSIFY_COMBINE]  = D_HT,
		[CLASSIFY_ANTLION]  = D_LI,
		[CLASSIFY_ZOMBIE]   = D_HT,
	},

	["zombie"] = { -- Zombies hate
		[CLASSIFY_NEUTRAL]  = D_HT,
		[CLASSIFY_ARMED]    = D_HT,
		[CLASSIFY_LONEWOLF] = loneWolf,
		[CLASSIFY_COMBINE]  = D_HT,
		[CLASSIFY_ANTLION]  = D_HT,
		[CLASSIFY_ZOMBIE]   = D_LI,
	},

	["misc"] = {
		[CLASSIFY_LONEWOLF] = loneWolf
	}
}

function GetClass(npc)
	return classMap[npc:Classify()] or "misc"
end

function GetDisposition(npc, ply)
	local val = classifications[GetClass(npc)][ply:GetClassification()]

	if isfunction(val) then
		local disposition, priority = val(ply, npc)

		return disposition, priority or 0
	end

	return val, 0
end

local function update(npc, ply, force)
	if not force and npc:Disposition(ply) == D_HT then
		return
	end

	local disposition, priority = GetDisposition(npc, ply)

	if not disposition then
		return
	end

	npc:AddEntityRelationship(ply, disposition, priority)
end

function UpdateDisposition(npc, target, force)
	if target then
		update(npc, target, force)

		return
	end

	for _, ply in player.Iterator() do
		update(npc, ply, force)
	end
end

function ApplyClassification(ply, class, force)
	ply.Classification = class

	for npc in pairs(EntityCache.Get("npcs")) do
		UpdateDisposition(npc, ply, force)
	end
end

function OnCreated(npc)
	npc:SetLagCompensated(true)
	npc:AddSpawnFlags(SF_NPC_NO_WEAPON_DROP)

	UpdateDisposition(npc, nil, true)
end

function CheckHeldWeapons()
	for _, ply in player.Iterator() do
		if not ply:Alive() or not ply:HasCharacter() then
			continue
		end

		local tab = ply:GetTable()
		local weapon = ply:GetActiveWeapon()
		local class = IsValid(weapon) and weapon:GetClass() or ""

		if not tab.LastWeapon then
			tab.LastWeapon = class
		end

		if tab.LastWeapon != class then
			ply:UpdateClassification()
		end

		tab.LastWeapon = class
	end
end

function HandlePlayerSpawn(ply)
	ply.LoneWolfCounter = 0
	ply.LastWeapon = nil

	ply:UpdateClassification(true)

	for npc in pairs(EntityCache.Get("npcs")) do
		npc:ClearEnemyMemory(ply)
	end
end

function OnDamaged(self, dmginfo)
	local attacker = dmginfo:GetAttacker()

	if not IsValid(attacker) or not attacker:IsPlayer() then
		return
	end

	if not self:Alive() then
		local config = Config.Get("LoneWolfCounter")

		-- Killing friendly NPC's gets you added to the shit list
		if config > 0 and GetDisposition(self, attacker) == D_LI then
			local count = (attacker.LoneWolfCounter or 0) + 1

			attacker.LoneWolfCounter = count

			if count == config then
				attacker:UpdateClassification()
			end
		end
	end

	-- Call out to friendlies in an area to help us
	local dist = Config.Get("NPCCalloutRadius")

	if dist > 0 then
		if self:Alive() and self.NextCallout and self.NextCallout < CurTime() then
			return
		end

		local pos = self:GetPos()

		self:AddEntityRelationship(attacker, D_HT, 10)
		self:UpdateEnemyMemory(attacker, attacker:GetPos())

		for npc in pairs(EntityCache.Get("npcs")) do
			if npc != self and npc:Disposition(self) == D_LI and npc:GetPos():Distance(pos) <= dist then
				npc:AddEntityRelationship(attacker, D_HT, 0)
			end
		end

		self.NextCallout = CurTime() + 0.5
	end
end
