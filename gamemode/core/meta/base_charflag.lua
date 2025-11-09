local FLAG = {}

FLAG.Name = "Unnamed Character Flag"
FLAG.Team = TEAM_UNASSIGNED

FLAG.BaseLanguage = "eng"

FLAG.Health = 100
FLAG.Armor = 0

FLAG.Scale = 1

FLAG.IStatSpeed = 5

-- First weapon on the list is selected on spawn
FLAG.Loadout = {}
FLAG.EquipmentSlots = {}

FLAG.Clothing = CLOTHING_NONE

FLAG.BloodColor = BLOOD_COLOR_RED

-- Min speed can be changed to <= 90 after my footstep plugin is ported over from helix
FLAG.SlowWalkSpeed = 91
FLAG.WalkSpeed = 91
-- FLAG.RunSpeed = 190 -- Gets overwritten later, just here for reference
FLAG.JumpPower = 200
FLAG.CrouchSpeed = 60

FLAG.CanChangeName = true
FLAG.CanChangeDescription = true

FLAG.AllowSpawngroups = true

function FLAG:Run(ply, name, ...)
	if isfunction(self[name]) then
		return self[name](self, ply, ...)
	else
		return util.SafeCopy(self[name])
	end
end

function FLAG:ScaleIStat(ply, field, min, max)
	local val = self:Run(ply, field)

	for _, item in pairs(ply:GetItems()) do
		local func = item["Get" .. field]

		if func then
			val = val + func(item, ply)
		end
	end

	for _, buff in pairs(ply:GetBuffs()) do
		local func = buff["Get" .. field]

		if func then
			val = val + func(buff, ply)
		end
	end

	return math.ClampedRemap(val, 1, 10, min, max)
end

function FLAG:RunSpeed(ply)
	return self:ScaleIStat(ply, "IStatSpeed", Config.Get("MinSpeed"), Config.Get("MaxSpeed"))
end

function FLAG:GetSpeeds(ply)
	return self.SlowWalkSpeed, self.WalkSpeed, self:Run(ply, "RunSpeed"), self.JumpPower, self.CrouchSpeed
end

function FLAG:VisibleRPName(ply)
	return ply:CharacterName()
end

function FLAG:VisibleDescription(ply)
	return ply:CharacterDescription()
end

function FLAG:PlayerScale(ply)
	return ply:CharacterScale() != 0 and ply:CharacterScale() or self.Scale
end

function FLAG:OnSpawn(ply)
end

function FLAG:GetModelData(ply)
	return {
		_base = {
			Model = ply:CharacterModel(),
			Skin = ply:CharacterSkin()
		}
	}
end

function FLAG:GetHandData(ply, data)
	return data
end

inherit.Register("charflag", "base", FLAG)
