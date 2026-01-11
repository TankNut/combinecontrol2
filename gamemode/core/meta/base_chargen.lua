local GENERATOR = {}

GENERATOR.Name = "Unnamed Character Generator"

GENERATOR.Permissions = {}
GENERATOR.Default = false

function GENERATOR:GetFields(ply)
	return {}
end

function GENERATOR:PostCreateCharacter(ply)
end

inherit.Register("chargen", "base", GENERATOR)
