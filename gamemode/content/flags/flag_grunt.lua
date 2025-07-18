FLAG.Name = "Unggoy"
FLAG.Team = TEAM_COVENANT

FLAG.Loadout = {"weapon_cc_hands"}

FLAG.EquipmentSlots = {
	"grunt",

	"primary",
	"secondary",
	"sidearm",
	"melee"
}

FLAG.SlowWalkSpeed = 80
FLAG.WalkSpeed = 80
FLAG.RunSpeed = 126
FLAG.JumpPower = 210
FLAG.CrouchSpeed = 80

FLAG.Clothing = CLOTHING_PARTIAL

local model = Model("models/valk/haloreach/covenant/characters/grunt/grunt_player.mdl")

function FLAG:GetModelData(ply)
	return {_base = {
		Model = model,
		Skin = 1
	}}
end

Hull.AddType("grunt", {
	Standing = {Vector(-10, -10, 0), Vector(10, 10, 55), Vector(0, 0, 42)},
	Crouching = {Vector(-10, -10, 0), Vector(10, 10, 55), Vector(0, 0, 30)},
})

Hull.AddModel("grunt",
	"models/valk/haloreach/covenant/characters/grunt/grunt_player.mdl",
	"models/valk/haloreach/covenant/characters/grunt/grunt_player_honor.mdl")
