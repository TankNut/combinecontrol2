CLASS.Name = "Citizen"
CLASS.SortOrder = 1

CLASS.Models = {
	Model("models/tnb/heads/trp/male_01.mdl"),
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
	{"Name", "Description"},
	{"Model", "Skin"}
}

CLASS.Options = {
	Name = {
		Name = "Name", Panel = "CC_CharCreate_Name",
		Field = "CharacterName",
		Args = {RandomNames = {"Masculine", "Feminine"}}
	},
	Description = {
		Name = "Description", Panel = "CC_CharCreate_Multiline",
		Field = "CharacterDescription",
		Args = {}
	},
	Model = {
		Name = "Model", Panel = "CC_CharCreate_Model",
		Field = "CharacterModel",
		Args = {Models = CLASS.Models}
	},
	Skin = {
		Name = "Skin", Panel = "CC_CharCreate_Skin",
		Field = "CharacterSkin",
		Args = {Option = "Model"}
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

	function CLASS:SetupModelPanel(panel, options, key)
		if key and not updateFields[key] then
			return
		end

		panel:SetModel(options.Model or self.Models[1])
		panel:SetSkin(options.Skin or 0)

		panel:SetParts({
			Body = {
				Model = string.format("models/tnb/clothing/trp/body/%s_survivor.mdl", util.GetModelGender(panel:GetModel()))
			}
		})
	end
end
