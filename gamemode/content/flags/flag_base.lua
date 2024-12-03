FLAG.Name = "Unnamed Character Flag"
FLAG.Team = TEAM_UNASSIGNED

FLAG.Health = 100
FLAG.Armor = 0

FLAG.Scale = 0

-- Last weapon on the list is selected on spawn
FLAG.Loadout = {}

FLAG.BloodColor = BLOOD_COLOR_RED

-- Min speed can be changed to <= 90 after my footstep plugin is ported over from helix
FLAG.SlowWalkSpeed = 91
FLAG.WalkSpeed = 91
FLAG.RunSpeed = 190
FLAG.JumpPower = 200
FLAG.CrouchSpeed = 60

function FLAG:GetSpeeds(ply)
	return self.SlowWalkSpeed, self.WalkSpeed, self.RunSpeed, self.JumpPower, self.CrouchSpeed
end

function FLAG:VisibleRPName(ply)
	return ply:CharacterName()
end

function FLAG:PlayerScale(ply)
	return self.Scale != 0 and self.Scale or ply:CharacterScale()
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
