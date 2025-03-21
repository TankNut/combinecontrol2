FLAG.Name = "Citizen"
FLAG.Team = TEAM_CITIZEN

FLAG.Loadout = {--[["weapon_cc_hands"]]}

FLAG.EquipmentSlots = {
	"test"
}

util.PrecacheModel("models/tnb/clothing/trp/body/male_survivor.mdl")
util.PrecacheModel("models/tnb/clothing/trp/body/female_survivor.mdl")

function FLAG:GetModelData(ply)
	local mdl = ply:CharacterModel()

	return {
		_base = {
			Model = mdl,
			Skin = ply:CharacterSkin()
		},
		Body = {
			Model = string.format("models/tnb/clothing/trp/body/%s_survivor.mdl", util.GetModelGender(mdl))
		}
	}
end
