module("Language", package.seeall)

Lookup = Lookup or {}

local PLAYER = FindMetaTable("Player")

CharacterVar.Add("Languages", {
	Default = {},
	Private = true,
	DataType = BLOB()
})

CharacterVar.Add("ActiveLanguage", {
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

function GetOverride(lang, index)
	local override = Get(lang).Override

	if override and override[index] then
		override = override[index]

		return isstring(override) and override or table.Random(override)
	end
end

function GetDefaultLanguages()
	local languages = {}

	for _, lang in ipairs(List) do
		if lang.Default then
			languages[lang.Command] = lang.Default
		end
	end

	return languages
end

function GM:CanSpeakLanguage(ply, lang)
	return ply:Languages()[lang] == true
end

function PLAYER:CanSpeakLanguage(lang)
	return hook.Run("CanSpeakLanguage", self, lang)
end

function GM:CanUnderstandLanguage(ply, lang)
	return ply:Languages()[lang] != nil
end

function PLAYER:CanUnderstandLanguage(lang)
	return hook.Run("CanUnderstandLanguage", self, lang)
end

if SERVER then
	function PLAYER:CheckLanguage()
		local languages = self:Languages()
		local active = self:ActiveLanguage()

		if not active or not Language.Lookup[active] or not languages[active] then
			for _, lang in pairs(Language.List) do
				if languages[lang.Command] then
					self:SetActiveLanguage(lang.Command)

					return
				end
			end

			self:SetActiveLanguage(nil)
		end
	end

	function PLAYER:GiveLanguage(lang, speak)
		speak = tobool(speak)

		local languages = self:Languages()

		languages[lang] = speak

		self:SetLanguages(languages)

		if not self:ActiveLanguage() and speak then
			self:SetActiveLanguage(lang)
		end
	end

	function PLAYER:TakeLanguage(lang)
		local languages = self:Languages()

		languages[lang] = nil

		self:SetLanguages(languages)

		if self:ActiveLanguage() == lang then
			self:CheckLanguage()
		end
	end
end
