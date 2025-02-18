local GENERATOR = {}

GENERATOR.Name = "Unnamed Character Generator"

function GENERATOR:GetFields(ply)
	return {}
end

function GENERATOR:GiveItem(ply, ...)
	local func = ply:IsTemporaryCharacter() and PLAYER.GiveTempItem or PLAYER.GiveItem

	func(ply, ...)
end

function GENERATOR:PostCreateCharacter(ply)
end

inherit.Register("chargen", "base", GENERATOR)
