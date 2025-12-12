FLAG.Name = "SPARTAN"
FLAG.Team = TEAM_UNSC

FLAG.Armor = 100

FLAG.Scale = 1.15

FLAG.IStatSpeed = 7

FLAG.Loadout = {"weapon_cc_hands"}

FLAG.EquipmentSlots = {
	"spartan",
	"spartan_arm",

	"primary",
	"secondary",
	"sidearm",
	"melee",
	"radio"
}

FLAG.Clothing = CLOTHING_PARTIAL

FLAG.Buffs = {"spartan_shield"}

local model = Model("models/models/valk/haloreach/unsc/spartan/spartan_vb.mdl")

function FLAG:GetModelData(ply)
	return {_base = {
		Model = model,
		Color = Color(74, 74, 74)
	}}
end
