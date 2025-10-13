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

Hull.AddType("elite", {
	Standing = {Vector(-16, -16, 0), Vector(16, 16, 85), Vector(0, 0, 70)},
	Crouching = {Vector(-16, -16, 0), Vector(16, 16, 65), Vector(0, 0, 50)},
})

Hull.AddModel("elite",
	Model("models/halo_reach/players/elite_field_marshall.mdl"),
	Model("models/halo_reach/players/elite_general.mdl"),
	Model("models/halo_reach/players/elite_minor.mdl"),
	Model("models/halo_reach/players/elite_officer.mdl"),
	Model("models/halo_reach/players/elite_ranger.mdl"),
	Model("models/halo_reach/players/elite_specops.mdl"),
	Model("models/halo_reach/players/elite_ultra.mdl"),
	Model("models/halo_reach/players/elite_zealot.mdl"))
