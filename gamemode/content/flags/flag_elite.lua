FLAG.Name = "Sangheili"
FLAG.Team = TEAM_COVENANT

FLAG.Loadout = {"weapon_cc_hands"}

FLAG.EquipmentSlots = {
	"elite",

	"primary",
	"secondary",
	"sidearm",
	"melee",
	"radio"
}

FLAG.SlowWalkSpeed = 80
FLAG.WalkSpeed = 80
FLAG.RunSpeed = 300
FLAG.JumpPower = 300
FLAG.CrouchSpeed = 80

FLAG.Clothing = CLOTHING_NONE

local model = Model("models/halo_reach/players/elite_minor.mdl")

function FLAG:GetModelData(ply)
	return {_base = {
		Model = model,
		Skin = 1
	}}
end
