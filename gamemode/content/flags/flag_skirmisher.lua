FLAG.Name = "Skirmisher"
FLAG.Team = TEAM_COVENANT

FLAG.Armor = 100

FLAG.Loadout = {"weapon_cc_hands"}

FLAG.EquipmentSlots = {
	"skirmisher",

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

FLAG.NoFallDamage = true
FLAG.OmniSprint = true
FLAG.SprintFiring = true

local model = Model("models/halo_reach/characters/players/covenant/skirmisher_minor.mdl")

function FLAG:GetModelData(ply)
	return {_base = {
		Model = model
	}}
end
