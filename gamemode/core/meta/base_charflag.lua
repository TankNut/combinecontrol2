local FLAG = {}

FLAG.Name = "Unnamed Character Flag"
FLAG.Team = TEAM_UNASSIGNED

FLAG.BaseLanguage = "eng"

FLAG.Health = 100
FLAG.Armor = 0

FLAG.Scale = 1

-- First weapon on the list is selected on spawn
FLAG.Loadout = {}
FLAG.EquipmentSlots = {}

FLAG.Clothing = CLOTHING_NONE

FLAG.BloodColor = BLOOD_COLOR_RED

-- Min speed can be changed to <= 90 after my footstep plugin is ported over from helix
FLAG.SlowWalkSpeed = 91
FLAG.WalkSpeed = 91
FLAG.RunSpeed = 190
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

function FLAG:GetSpeeds(ply)
	return self.SlowWalkSpeed, self.WalkSpeed, self.RunSpeed, self.JumpPower, self.CrouchSpeed
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

inherit.Register("charflag", "base", FLAG)
