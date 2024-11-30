PlayerVar.Add("CharID", {Default = 0})
PlayerVar.Add("CharacterList", {Default = {}, Private = true})

PlayerVar.Add("VisibleRPName", {Default = "Unconnected"})
PlayerVar.Add("ShortDescription", {Default = ""})

CharacterVar.Add("Name", {
	Default = "Unknown",
	Private = true,
	DataType = VARCHAR(64)
})

CharacterVar.Add("NameOverride", {
	Default = "",
	Private = true,
	DataType = VARCHAR(64)
})

CharacterVar.Add("Description", {
	Default = "",
	Private = true,
	DataType = TEXT()
})

CharacterVar.Add("Model", {
	Default = "models/player/skeleton.mdl",
	ServerOnly = true,
	DataType = VARCHAR(128)
})

CharacterVar.Add("Skin", {
	Default = 0,
	ServerOnly = true,
	DataType = TINYINT()
})

local meta = FindMetaTable("Player")

function meta:HasCharacter()
	return self:CharID() != 0
end

function meta:HasTemporaryCharacter()
	return self:CharID() < 0
end

function GM:PlayerCharacterListChanged(ply, old, new, loading)
	if CLIENT and loading then
		self.CCMode = table.Count(new) > 0 and CC_CREATESELECT_C or CC_CREATE
		self:CreateCharEditor()
	end
end

function GM:PostLoadCharacter(ply)
	if CLIENT then
		-- This needs to become a var
		GAMEMODE.LastLanguage = nil
	end

	hook.Run("PlayerApplyFlag", ply)

	if SERVER then
		ply:Spawn()
	end
end

if CLIENT then
	netstream.Hook("PostLoadCharacter", function()
		hook.Run("PostLoadCharacter", lp)
	end)
end
