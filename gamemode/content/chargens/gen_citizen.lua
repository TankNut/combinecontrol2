GENERATOR.Name = "Citizen"

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

function GENERATOR:PostCreateCharacter(ply, temp)
end
