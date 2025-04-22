GENERATOR.Name = "UNSC/Marine"

local models = Config.Get("BaseModels")

function GENERATOR:GetFields(ply)
	local mdl = table.Random(models)
	local isFemale = util.GetModelGender(mdl) == "female"

	local name

	if isFemale then
		name = CharacterCreate.GetRandomName("English/Feminine")
	else
		name = CharacterCreate.GetRandomName("English/Masculine")
	end

	local desc = string.format([[A height between 5'2 - 6'2, [blank] accent, ect ect]])

	return {
		CharacterName = name,
		CharacterDescription = desc,
		CharacterModel = mdl,
		Languages = Language.GetDefaultLanguages()
	}
end

function GENERATOR:PostCreateCharacter(ply)
	ply:GiveItem("undersuit_marine_brown"):SetEquipmentSlot("unsc_undersuit")

	local armor = ply:GiveItem("armor_marine")
	armor:SetData("ShoulderPads", 2)
	armor:SetData("ChestPacks", 2)
	armor:SetData("Legs", 1)
	armor:SetEquipmentSlot("unsc_armor")

	local helmet = ply:GiveItem("helmet_marine")
	helmet:SetData("Balaclava", true)
	helmet:SetEquipmentSlot("unsc_headwear")
end
