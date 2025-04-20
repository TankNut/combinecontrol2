FLAG.Name = "UNSC"
FLAG.Team = TEAM_UNSC

FLAG.Loadout = {"weapon_cc_hands"}

FLAG.EquipmentSlots = {
	"test"
}

FLAG.Clothing = CLOTHING_FULL

function FLAG:GetModelData(ply)
	return {_base = {
		Model = ply:CharacterModel(),
		Skin = ply:CharacterSkin()
	}}
end
