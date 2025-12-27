FLAG.Base = "grunt"

FLAG.Name = "Grunt Honor Guard"

FLAG.Armor = 100

local model = Model("models/valk/haloreach/covenant/characters/grunt/grunt_player_honor.mdl")

function FLAG:GetModelData(ply)
	return {_base = {
		Model = model
	}}
end
