CLASS.Name = "Spartan"
CLASS.SortOrder = 2

CLASS.Permissions = {"character_spartan"}

CLASS.OptionalLanguages = {
	"rus", "spa", "chi",
	"hin", "por", "rus",
	"ger", "jpn", "fra",
	"kor", "hun", "swa"
}

CLASS.Fields = {
	Languages = Language.GetDefaultLanguages()
}

CLASS.Pages = {
	{Name = "Basic Information", Options = {"Name", "Description"}},
	{Name = "Options", Options = {"Language"}}
}

CLASS.Options = {
	Name = {
		Name = "Name", Panel = "CC_CharCreate_Name",
		Description = "Your text here!\nAnd here!",
		Field = "CharacterName",
		Args = {
			"Spartan-II/Masculine",
			"Spartan-II/Feminine",
			"Spartan-II/Unisex",

			"Spartan-III/Masculine",
			"Spartan-III/Feminine",
			"Spartan-III/Unisex"
		}
	},
	Description = {
		Name = "Description", Panel = "CC_CharCreate_Multiline",
		Field = "CharacterDescription",
	},
	Language = {
		Name = "Extra Language", Panel = "CC_CharCreate_Dropdown",
		Args = table.Add({
			{Name = "None", Value = nil},
		}, table.Map(CLASS.OptionalLanguages, function(lang)
			return {Name = Language.Get(lang).Name, Value = lang}
		end))
	}
}

CLASS.Validate = {
	Name = Config.Get("CharacterNameRules"),
	Description = Config.Get("CharacterDescriptionRules"),
	Language = {
		validate.String(),
		validate.InList(CLASS.OptionalLanguages)
	}
}

if CLIENT then
	function CLASS:GetAppearance(options, key)
		return {_base = {
			Model = Model("models/models/valk/haloreach/unsc/spartan/spartan_vb.mdl"),
			Color = Color(70, 70, 70)
		}}
	end
else
	function CLASS:PreCreateCharacter(ply, fields, options)
		options.Description = string.Escape(options.Description)

		if options.Language then
			fields.Languages[options.Language] = true
		end
	end

	function CLASS:PostCreateCharacter(ply, options)
		ply:SetCharacterFlag("spartan")
		ply:GiveItem("spartan"):SetEquipmentSlot("spartan")
	end
end
