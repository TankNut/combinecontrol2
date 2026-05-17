module("Stash", package.seeall)

local PLAYER = FindMetaTable("Player")

CharacterVar.Add("StashData", {
	Default = {},
	Private = true,

	Field = "Stash",
	DataType = BLOB()
})

GlobalVar.Add("StashVersion", {
	Default = 1,
	Persist = true,
	Mode = GLOBALVAR_MAP
})

function PLAYER:GetStashData()
	return self:StashData()[game.GetMapOverride()]
end

function PLAYER:HasStash()
	return tobool(self:GetStashData())
end

function PLAYER:CanAccessStash()
	local data = self:GetStashData()

	if not data then
		return false, "You don't have a stash on this map!"
	end

	if data.Cooldown and os.time() < data.Cooldown then
		return false, string.format("You have to wait another %s before you can access your stash!", string.NiceTime(data.Cooldown - os.time()))
	end

	return data.Pos:Distance(self:GetPos()) <= Config.Get("StashRange"), "You're too far away from your stash!"
end

function GM:OnStashDataChanged(ply, old, new, loaded)
	local data = new[game.GetMapOverride()]

	if data then
		if SERVER and loaded and data.Version != GAMEMODE:StashVersion() then
			new[game.GetMapOverride()] = nil

			ply:SendChat("NOTICE", "Stashes on this map have been reset since you've last played on this character.")
			ply:SetStashData(new)
		elseif CLIENT then
			StashPos = data.Pos
			StashAng = data.Ang
		end
	elseif CLIENT then
		StashPos = nil
		StashAng = nil

		SafeRemoveEntity(CSEnt)
	end
end

if CLIENT then
	CSEnt = CSEnt

	StashPos = StashPos
	StashAng = StashAng

	OffsetPos = Vector(-3.5, 0, 2.5)
	OffsetAng = Angle(5.5, 8.4, 6.5)

	function CreateCSEnt()
		if IsValid(CSEnt) then
			CSEnt:Remove()
		end

		CSEnt = ClientsideModel("models/gta iv/duffle_bag.mdl")

		return CSEnt
	end

	function GM:PostDrawOpaqueRenderables(depth, skybox)
		if skybox then
			return
		end

		if StashPos then
			local ent = IsValid(CSEnt) and CSEnt or CreateCSEnt()
			local pos, ang = LocalToWorld(OffsetPos, OffsetAng, StashPos, StashAng)

			ent:SetPos(pos)
			ent:SetAngles(ang)
		end
	end
else
	function Set(ply, pos, ang)
		local map = game.GetMapOverride()
		local stashData = ply:StashData()

		stashData[map] = {
			Cooldown = ply:HasStash() and os.time() + Config.Get("StashCooldown") or nil,
			Pos = pos,
			Ang = ang,
			Version = GAMEMODE:StashVersion()
		}

		ply:SetStashData(stashData)
	end
end
