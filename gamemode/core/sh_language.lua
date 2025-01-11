module("Language", package.seeall)

Lookup = Lookup or {}

local meta = FindMetaTable("Player")

CharacterVar.Add("Languages", {
	Default = {},
	Private = true,
	DataType = BLOB()
})

CharacterVar.Add("ActiveLanguage", {
	Default = "",
	Private = true,
	DataType = VARCHAR(32)
})

function Load()
	List = GM.Languages

	for _, data in ipairs(List) do
		Lookup[data.Command] = data
	end
end

function Get(lang)
	return Lookup[lang]
end

if SERVER then
	function SetupCharacter(fields)
		local field = {}

		for _, v in ipairs(List) do
			if field.Default then
				field[v.Command] = field.Default
			end
		end
	end
end

function meta:CanSpeakLanguage(lang)
	return hook.Run("CanSpeakLanguage", self, lang)
end

function meta:CanUnderstandLanguage(lang)
	return hook.Run("CanUnderstandLanguage", self, lang)
end

if SERVER then
	function meta:CheckLanguage()
		local languages = self:GetLanguages()
		local active = self:GetActiveLanguage()

		if not Language.Lookup[active] or not languages[active] then
			for _, v in pairs(Language.List) do
				if languages[v[1]] then
					self:SetActiveLanguage(v[1])

					return
				end
			end

			self:SetActiveLanguage(nil)
		end
	end

	function meta:GiveLanguage(lang, speak)
		speak = tobool(speak)

		local languages = self:Languages()

		languages[lang] = speak

		self:SetLanguages(languages)

		if not self:ActiveLanguage() and speak then
			self:SetActiveLanguage(lang)
		end
	end

	function meta:TakeLanguage(lang)
		local languages = self:Languages()

		languages[lang] = nil

		self:SetLanguages(languages)

		if self:ActiveLanguage() == lang then
			self:CheckLanguage()
		end
	end
end

function GM:CanSpeakLanguage(ply, lang)
	return ply:Languages()[lang] == true
end

function GM:CanUnderstandLanguage(ply, lang)
	return ply:Languages()[lang] != nil
end
