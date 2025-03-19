PlayerVar.Add("CharID", {Default = 0})
PlayerVar.Add("CharacterList", {Default = {}, Private = true})

PlayerVar.Add("VisibleRPName", {Default = "Unconnected"})
PlayerVar.Add("VisibleDescription", {Default = "", Private = true})
PlayerVar.Add("ShortDescription", {Default = ""})

CharacterVar.Add("CharacterName", {Default = "Unknown", Private = true, Field = "Name", DataType = VARCHAR(64)})
CharacterVar.Add("CharacterNameOverride", {Default = "", Private = true, Field = "NameOverride", DataType = VARCHAR(64)})

CharacterVar.Add("CharacterDescription", {Default = "", Private = true, Field = "Description", DataType = TEXT()})
CharacterVar.Add("CharacterNotes", {Default = "", Private = true, Field = "Notes", DataType = TEXT()})

CharacterVar.Add("CharacterModel", {Default = "models/player/skeleton.mdl", ServerOnly = true, Field = "Model", DataType = VARCHAR(128)})
CharacterVar.Add("CharacterSkin", {Default = 0, ServerOnly = true, Field = "Skin", DataType = TINYINT()})

CharacterVar.Add("CharacterHidden", {Default = 0, Field = "Hidden", DataType = TINYINT()})
CharacterVar.Add("CharacterLastSeen", {Default = 0, ServerOnly = true, DataType = UINT()})

CharacterVar.Add("Spawngroup", {Default = "", Private = true, DataType = VARCHAR(32)})

local PLAYER = FindMetaTable("Player")

function PLAYER:HasCharacter()
	return self:CharID() != 0
end

function PLAYER:IsTemporaryCharacter()
	return self:CharID() < 0
end

function GM:OnCharacterListChanged(ply, old, new, loaded)
	if CLIENT and (loaded or GUI.Get("CharacterSelect")) then
		GUI.Open("CharacterSelect")
	end
end

function GM:OnCharIDChanged(ply, old, new, loaded)
	if CLIENT and ply == lp then
		if new == 0 then
			GUI.Open("CharacterSelect")

			Hud.Rebuild()

			return
		end

		local crc = util.CRC(GAMEMODE.MOTD)

		if crc != cookie.GetString("cc_motd", "") then
			GUI.Open("MOTD")

			cookie.Set("cc_motd", crc)
		end
	end
end

function GM:PostLoadCharacter(ply)
	if CLIENT then
		GUI.Close("CharacterCreate")
		GUI.Close("CharacterSelect")

		Hud.Rebuild()
	end

	ply:SetScale(0, true)

	hook.Run("PlayerApplyFlag", ply)

	if SERVER then
		Log.Write("character_load", ply)

		ply:SetCharacterLastSeen(os.time())

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

function GM:CanChangeCharacterName(ply)
	if not ply:RunCharFlag("CanChangeName") then
		return false
	end

	return #ply:CharacterNameOverride() == 0
end

function GM:CanChangeCharacterDescription(ply)
	return tobool(ply:RunCharFlag("CanChangeDescription"))
end

if CLIENT then
	function GM:ShouldHidePlayer(ply)
		return ply:CharacterHidden() == 1 or ply:RunCharFlag("ShouldHidePlayer")
	end

	netstream.Hook("PostLoadCharacter", function()
		hook.Run("PostLoadCharacter", lp)
	end)
end
