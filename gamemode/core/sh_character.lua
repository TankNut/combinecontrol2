PlayerVar.Add("CharID", {Default = 0})
PlayerVar.Add("CharacterList", {Default = {}, Private = true})

PlayerVar.Add("VisibleRPName", {Default = "Unconnected"})
PlayerVar.Add("ShortDescription", {Default = ""})

CharacterVar.Add("CharacterName", {Default = "Unknown", Private = true, Field = "Name", DataType = VARCHAR(64)})
CharacterVar.Add("CharacterNameOverride", {Default = "", Private = true, Field = "NameOverride", DataType = VARCHAR(64)})

CharacterVar.Add("CharacterDescription", {Default = "", Private = true, Field = "Description", DataType = TEXT()})

CharacterVar.Add("CharacterModel", {Default = "models/player/skeleton.mdl", ServerOnly = true, Field = "Model", DataType = VARCHAR(128)})
CharacterVar.Add("CharacterSkin", {Default = 0, ServerOnly = true, Field = "Skin", DataType = TINYINT()})

local meta = FindMetaTable("Player")

function meta:HasCharacter()
	return self:CharID() != 0
end

function meta:IsTemporaryCharacter()
	return self:CharID() < 0
end

function GM:OnCharacterListChanged(ply, old, new, loaded)
	if CLIENT and (loaded or GUI.Get("CharacterSelect")) then
		GUI.Open("CharacterSelect")
	end
end

function GM:OnCharIDChanged(ply, old, new, loaded)
	if CLIENT and ply == lp then
		if old == 0 then
			self:CreateMOTD()
		elseif new == 0 then
			GUI.Open("CharacterSelect")
		end
	end
end

function GM:PostLoadCharacter(ply)
	if CLIENT then
		GUI.Close("CharacterCreate")
		GUI.Close("CharacterSelect")
	end

	ply:SetScale(0, true)

	hook.Run("PlayerApplyFlag", ply)

	if SERVER then
		ply:Spawn()
		ply:CheckLanguage()
	end
end

function GM:OnCharacterModelChanged(ply, old, new, loaded)
	if SERVER and not loaded then ply:UpdateAppearance() end
end

function GM:OnCharacterSkinChanged(ply, old, new, loaded)
	if SERVER and not loaded then ply:UpdateAppearance() end
end

if CLIENT then
	netstream.Hook("PostLoadCharacter", function()
		hook.Run("PostLoadCharacter", lp)
	end)
end
