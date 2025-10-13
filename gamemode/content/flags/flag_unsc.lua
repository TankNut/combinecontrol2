FLAG.Name = "UNSC"
FLAG.Team = TEAM_UNSC

FLAG.Loadout = {"weapon_cc_hands"}

FLAG.EquipmentSlots = {
	"unsc_headwear",
	"unsc_back",
	"unsc_armor",
	"unsc_undersuit",

	"primary",
	"secondary",
	"sidearm",
	"melee",
	"radio"
}

FLAG.Clothing = CLOTHING_FULL

function FLAG:GetModelData(ply)
	return {_base = {
		Model = ply:CharacterModel(),
		Skin = ply:CharacterSkin()
	}}
end
