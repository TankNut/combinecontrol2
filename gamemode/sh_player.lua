local PLAYER = FindMetaTable("Player")

GM.PlayerAccessors = {
	{"NewbieStatus", 		false, 	"Float", 	NEWBIE_STATUS_NEW},
	{"Description",			false, 	"String", 	""},
	{"Holstered", 			false, 	"Bit", 		true},
	{"Trait", 				false, 	"Float", 	TRAIT_NONE},
	{"CombineFlag", 		false, 	"String", 	""},
	{"CombineSquad",		false,	"String",	""},
	{"CombineSquadID",		false,	"Float",	4},
	{"ActiveFlag", 			false, 	"String", 	""},
	{"Consciousness", 		true, 	"Float", 	100},
	{"PassedOut", 			false, 	"Bit", 		false},
	{"TiedUp",				false,	"Bit",		false},
	{"CharCreationDate",	true,	"String",	""},
	{"InAttack2",			false,	"Bit",		false},
	{"BusinessLicenses",	false,	"Float",	0},
	{"Typing",				false,	"Float",	0},
	{"PropProtection",		true,	"Table",	{}},
	{"RagdollIndex",		false,	"Float",	-1},
	{"HideAdmin",			false,	"Bit",		false},
	{"Hidden",				false, 	"Bit",		false},
	{"LastPMSender",		true,	"String",	""},
	{"LastNotesUpdate", 	false, 	"Float", 	0},
	{"IsTravelBanned", 		false, 	"Bit", 		false},
	{"AdminRadio", 			true, 	"Bit", 		false},
	{"PlayerScale",			false,	"Float",	1},
	{"CharacterScale", 		true, 	"Float", 	1},
	{"InfiniteAmmo", 		false, 	"Bit", 		false},
	{"OverlayMode", 		true, 	"Float", 	OVERLAY_NONE},
	{"ThermalHidden", 		false, 	"Bit", 		false},
	{"JumpPackActive", 		false, 	"Bit", 		false},
	{"Hunger", 				true, 	"Float", 	0},
	{"ZoneMins", 			true, 	"Vector", 	Vector()},
	{"ZoneMaxs", 			true, 	"Vector", 	Vector()},
	{"ArmoryAccess", 		true, 	"String", 	""},
}

for k, v in pairs(GM.PlayerAccessors) do
	local name, private, vartype, default = v[1], v[2], v[3], v[4]

	PLAYER["Set" .. name] = function(ply, val, force)
		if val == nil then
			return
		end

		if SERVER then
			if ply[name .. "Val"] == val and vartype != "Table" and not force then
				return
			end

			ply[name .. "Val"] = val

			hook.Run("On" .. name .. "Changed", ply, val)

			if private then
				if ply:IsBot() then
					return
				end

				net.Start("nSet" .. name)
					net["Write" .. vartype](val)
				net.Send(ply)
			else
				net.Start("nSet" .. name)
					net.WriteEntity(ply)
					net["Write" .. vartype](val)
				net.Broadcast()
			end
		end

		if CLIENT then
			if vartype == "Bit" then
				val = tobool(val)
			end

			ply[name .. "Val"] = val
		end

		return val
	end

	PLAYER[name] = function(ply)
		if ply[name .. "Val"] == nil then
			return default
		end

		if ply[name .. "Val"] == false then
			return false
		end

		return ply[name .. "Val"]
	end

	if SERVER then
		util.AddNetworkString("nSet" .. name)
	end

	if CLIENT then
		net.Receive("nSet" .. name, function()
			local ply
			local val

			if private then
				ply = LocalPlayer()
				val = net["Read" .. vartype]()

				if vartype == "Bit" then
					val = tobool(val)
				end

				LocalPlayer()[name .. "Val"] = val
			else
				ply = net.ReadEntity()
				val = net["Read" .. vartype]()

				if vartype == "Bit" then
					val = tobool(val)
				end

				ply[name .. "Val"] = val
			end

			if IsValid(ply) then
				hook.Run("On" .. name .. "Changed", ply, val)
			end
		end)
	end
end

hook.Add("OnEntityCreated", "SH.Player.OnEntityCreated", function(ent)
	if ent:IsPlayer() then
		ent.Augments = {}
		ent.Equipment = {}
		ent.Inventory = {}
	end
end)

function PLAYER:SyncAllData(ply)
	for _, v in pairs(GAMEMODE.PlayerAccessors) do
		local name, private, vartype = v[1], v[2], v[3]

		if not private then

			net.Start("nSet" .. name)
				net.WriteEntity(self)
				net["Write" .. vartype](self[name](self))
			if ply then
				net.Send(ply)
			else
				net.Broadcast()
			end
		end
	end
end

function PLAYER:SyncAllOtherData()
	for _, v in player.Iterator() do

		if v != self then

			for _, n in pairs(GAMEMODE.PlayerAccessors) do

				if not n[2] then

					net.Start("nSet" .. n[1])
						net.WriteEntity(v)
						net["Write" .. n[3]](v[n[1]](v))
					net.Send(self)

				end

			end

		end

	end
end

net.Receive("nRequestPlayerData", function(len, ply)
	if CLIENT then return end

	local ent = net.ReadEntity()
	if not ent or not ent:IsValid() then return end

	ent:SyncAllData(ply)
end)

net.Receive("nRequestAllPlayerData", function(len, ply)
	if CLIENT then return end

	if not ply.NextSyncPlayerData then ply.NextSyncPlayerData = 0 end

	if CurTime() < ply.NextSyncPlayerData then return end

	ply.NextSyncPlayerData = CurTime() + 1

	ply:SyncAllOtherData()
end)

function GM:FreezePlayer(ply, time)
	ply.FreezeTime = math.max(ply.FreezeTime or 0, CurTime() + time)
end

function GM:Move(ply, move)
	if not ply:HasCharacter() then
		return true
	end

	if ply.FreezeTime and CurTime() < ply.FreezeTime then
		move:SetMaxSpeed(0)
		move:SetMaxClientSpeed(0)
		move:SetVelocity(Vector())
	end

	if ply:PassedOut() then
		move:SetMaxSpeed(0)
		move:SetMaxClientSpeed(0)
		move:SetVelocity(Vector())
	end

	local func = ply:RunCharFlag("Move")

	if func then
		func(ply, move)
	end

	return self.BaseClass:Move(ply, move)
end

function GM:SetupMove(ply, move)
	if ply.FreezeTime and CurTime() < ply.FreezeTime then
		move:SetMaxSpeed(0)
		move:SetMaxClientSpeed(0)
		move:SetVelocity(Vector())
	end

	if ply:PassedOut() then
		move:SetMaxSpeed(0)
		move:SetMaxClientSpeed(0)
		move:SetVelocity(Vector())
	end

	return self.BaseClass:SetupMove(ply, move)
end

function PLAYER:Ragdoll()
	if self:RagdollIndex() == -1 then return NULL end

	return ents.GetByIndex(self:RagdollIndex())
end

function PLAYER:SetRagdoll(ent)
	self:SetRagdollIndex(ent:EntIndex())
end

GM.WalkSounds = {}

GM.RunSounds = {}

function GM:PlayerFootstep(ply, pos, foot, s, vol, rf)
	if SERVER or ply:RunCharFlag("QuietSteps") then return end

	local mdl = ply:GetModel()
	local snd = ""

	local data = self.WalkSounds[mdl]

	if data then
		if type(data) == "table" then
			snd = foot == 0 and data[1] or data[2]
		else
			snd = data
		end
	end

	data = self.RunSounds[mdl]

	if data and ply:GetVelocity():Length2D() > 150 then
		if type(data) == "table" then
			snd = foot == 0 and data[1] or data[2]
		else
			snd = data
		end
	end

	if #snd > 0 then
		ply:EmitSound(snd, 75, 100, vol, CHAN_BODY)

		return true
	end

	self.BaseClass:PlayerFootstep(ply, pos, foot, s, vol, rf)
end

function GM:PlayerStepSoundTime(ply, stepType, walking)
	return self.BaseClass:PlayerStepSoundTime(ply, stepType, walking)
end

function player.GetByCharID(id)
	for _, v in player.Iterator() do

		if v:CharID() == id then
			return v
		end
	end
end

function PLAYER:HasFaceCovered()
	for k, v in pairs(self.Equipment) do
		if v.CoversFace then
			return true
		end
	end

	return false
end

function PLAYER:IsGasImmune()
	if self:GetMoveType() == MOVETYPE_NOCLIP or self:RunCharFlag("GasImmune", false) then
		return true
	end

	local val = 0

	for k, v in pairs(self.Equipment) do
		local immunity = v:GetGasImmunity()

		if immunity == true then
			return true
		end

		if isnumber(immunity) then
			val = math.max(val, immunity)
		end
	end

	return val != 0 and val or false
end

function PLAYER:IsArmed()
	local wep = self:GetActiveWeapon()

	if IsValid(wep) then
		local class = wep:GetClass()

		if class != "weapon_cc_hands" and class != "weapon_physgun" and class != "gmod_tool" and class != "weapon_physcannon" then
			return true
		end
	end

	return false
end

function PLAYER:CanIgnoreTravelRestrictions(chardata)
	return self:IsAdmin()
	-- if self:IsAdmin() then return true end
	-- if not chardata then return false end

	-- if chardata.CharFlags and #chardata.CharFlags > 0 then
	-- 	local charFlags = GAMEMODE:LookupCharFlag(chardata.CharFlags)

	-- 	for _, v in pairs(charFlags) do
	-- 		if v and v.IgnoreTravelRestriction then
	-- 			return v.IgnoreTravelRestriction
	-- 		end
	-- 	end
	-- end

	-- return false
end

function GM:GetPlayerByCharID(id)
	for _, v in player.Iterator() do
		if v:CharID() == id then
			return v
		end
	end
end

local blacklist = {
	ammo_40mm = true,
	ammo_rpg = true,
	ammo_20mm = true
}

function PLAYER:HasInfiniteAmmo(ammo)
	if self:InfiniteAmmo() then
		return true
	end

	if self:DonatorActive() and not blacklist[ammo] then
		return true
	end

	return self:RunCharFlag("InfiniteAmmo")
end

function PLAYER:GetPlayerColor()
	return Vector(0.2, 0.2, 0.2)
end
