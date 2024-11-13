PlayerVar.Add("CharID", {Default = 0})
PlayerVar.Add("CharacterList", {Default = {}, Private = true})

PlayerVar.Add("VisibleRPName", {Default = "Unconnected"})
PlayerVar.Add("ShortDescription", {Default = ""})

CharacterVar.Add("Name", {
	Default = "Unknown",
	Private = true,
	Persist = true,
	DataType = VARCHAR(64)
})

CharacterVar.Add("Description", {
	Default = "",
	Private = true,
	Persist = true,
	DataType = TEXT()
})

CharacterVar.Add("Model", {
	Default = "models/player/skeleton.mdl",
	ServerOnly = true,
	Persist = true,
	DataType = VARCHAR(128)
})

CharacterVar.Add("Skin", {
	Default = 0,
	ServerOnly = true,
	Persist = true,
	DataType = TINYINT()
})

local meta = FindMetaTable("Player")

function meta:HasCharacter()
	return self:CharID() != 0
end

function meta:HasTemporaryCharacter()
	return self:CharID() < 0
end
