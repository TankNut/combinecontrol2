CLASS.Name = "Citizen"
CLASS.SortOrder = 1

CLASS.Models = {
	Model("models/tnb/heads/trp/male_01.mdl"),
	Model("models/tnb/heads/trp/male_02.mdl"),
	Model("models/tnb/heads/trp/male_03.mdl"),
	Model("models/tnb/heads/trp/male_04.mdl"),
	Model("models/tnb/heads/trp/male_05.mdl"),
	Model("models/tnb/heads/trp/male_06.mdl"),
	Model("models/tnb/heads/trp/male_07.mdl"),
	Model("models/tnb/heads/trp/male_08.mdl"),
	Model("models/tnb/heads/trp/male_09.mdl"),
	Model("models/tnb/heads/trp/female_01.mdl"),
	Model("models/tnb/heads/trp/female_02.mdl"),
	Model("models/tnb/heads/trp/female_03.mdl"),
	Model("models/tnb/heads/trp/female_04.mdl"),
	Model("models/tnb/heads/trp/female_05.mdl"),
	Model("models/tnb/heads/trp/female_38.mdl"),
	Model("models/tnb/heads/trp/female_53.mdl")
}

CLASS.Fields = {
	Languages = Language.GetDefaultLanguages()
}

CLASS.Pages = {
	{Name = "Basic Information", Options = {"Name", "Description"}},
	{Name = "Appearance", Options = {"Model", "Skin"}},
	{Name = "Options", Options = {"Language"}}
}

CLASS.Options = {
	Name = {
		Name = "Name", Panel = "CC_CharCreate_Name",
		Field = "CharacterName",
		Args = {
			"English/Masculine",
			"English/Feminine",
			"English/Unisex"
		}
	},
	Description = {
		Name = "Description", Panel = "CC_CharCreate_Multiline",
		Field = "CharacterDescription",
	},
	Model = {
		Name = "Model", Panel = "CC_CharCreate_Model",
		Field = "CharacterModel",
		Args = CLASS.Models
	},
	Skin = {
		Name = "Skin", Panel = "CC_CharCreate_Skin",
		Field = "CharacterSkin",
		Args = "Model"
	}
}

CLASS.Validate = {
	Name = {
		validate.Required(),
		validate.String(),
		validate.Min(Config.Get("MinNameLength")),
		validate.Max(Config.Get("MaxNameLength")),
		validate.AllowedCharacters(Config.Get("AllowedNameCharacters"))
	},
	Description = {
		validate.Required(),
		validate.String(),
		validate.Max(Config.Get("MaxDescLength")),
		validate.AllowedCharacters(Config.Get("AllowedNameCharacters"))
	},
	Model = {
		validate.Required(),
		validate.String(),
		validate.InList(CLASS.Models)
	},
	Skin = {
		validate.Required(),
		validate.Number(),
		validate.Min(0),
		validate.Callback(function(val)
			return val < util.GetModelSkins(validate.Cache.Model), "Skin index out of bounds"
		end)
	}
}

if CLIENT then
	local updateFields = table.Lookup({
		"Model", "Skin"
	})

	function CLASS:GetAppearance(options, key)
		if key and not updateFields[key] then
			return
		end

		local base = {
			Model = options.Model or self.Models[1],
			Skin = options.Skin or 0
		}

		local body = {
			Model = string.format("models/tnb/clothing/trp/body/%s_survivor.mdl", util.GetModelGender(base.Model))
		}

		return {
			_base = base,
			Body = body
		}
	end
end
