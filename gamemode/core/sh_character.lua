module("Character", package.seeall)

PlayerVar.Add("CharID", {Default = 0})
PlayerVar.Add("CharacterList", {Default = {}, Private = true})

PlayerVar.Add("VisibleRPName", {Default = "Unconnected"})
PlayerVar.Add("VisibleDescription", {Default = "", Private = true})
PlayerVar.Add("ShortDescription", {Default = ""})

CharacterVar.Add("IsEventCharacter", {Default = false, Field = "EventCharacter", DataType = BOOL()})

CharacterVar.Add("CharacterName", {Default = "Unknown", Private = true, Field = "Name", DataType = VARCHAR(64)})
CharacterVar.Add("CharacterNameOverride", {Default = "", Private = true, Field = "NameOverride", DataType = VARCHAR(64)})

CharacterVar.Add("CharacterDescription", {Default = "", Private = true, Field = "Description", DataType = TEXT()})
CharacterVar.Add("CharacterNotes", {Default = "", Private = true, Field = "Notes", DataType = TEXT()})

CharacterVar.Add("CharacterModel", {Default = "models/player/skeleton.mdl", Field = "Model", DataType = VARCHAR(128)})
CharacterVar.Add("CharacterSkin", {Default = 0, Field = "Skin", DataType = TINYINT()})

CharacterVar.Add("AppearanceOverride", {DataType = BLOB(), ServerOnly = true})

CharacterVar.Add("CharacterHidden", {Default = false, Field = "Hidden", DataType = BOOL()})
CharacterVar.Add("CharacterLastSeen", {Default = 0, ServerOnly = true, Field = "LastSeen", DataType = UINT()})

CharacterVar.Add("Spawngroup", {Default = "", Private = true, DataType = VARCHAR(32)})

local PLAYER = FindMetaTable("Player")

function GetByID(id)
	for _, ply in player.Iterator() do
		if ply:CharID() == id then
			return ply
		end
	end
end

function PLAYER:HasCharacter()
	return self:CharID() != 0
end

function GM:OnCharacterListChanged(ply, old, new, loaded)
	if CLIENT then
		jank(function()
			if not ply:HasCharacter() or ui.Get("CharacterSelect") then
				ui.Open("CharacterSelect")
			end
		end)
	end
end

function GM:OnCharIDChanged(ply, old, new, loaded)
	if CLIENT and ply == lp then
		-- Don't remove, used to prevent cl_fullupdate from killing people's huds
		Hud.Rebuild()

		if new == 0 then
			ui.Open("CharacterSelect")

			return
		end

		local crc = util.CRC(GAMEMODE.MOTD)

		if crc != cookie.GetString("cc_motd", "") then
			ui.Open("MOTD")

			cookie.Set("cc_motd", crc)
		end
	end
end

function GM:PostLoadCharacter(ply)
	if CLIENT then
		ui.Close("CharacterCreate")
		ui.Close("CharacterSelect")
		ui.Close("CharacterGen")

		Hud.Rebuild()
	end

	ply:SetScale(1)
	ply:ApplyFlag()

	if CLIENT then
		Log.WriteHint("Character Loaded: " .. ply:VisibleRPName())
	else
		Log.Write("character_load", ply)

		ply:SetCharacterLastSeen(os.time())

		ply:Spawn()
		ply:CheckLanguage()

		if ply.FirstLoad then
			ply.FirstLoad = false
		end
	end
end

function GM:OnCharacterModelChanged(ply, old, new, loaded) if SERVER and not loaded then ply:UpdateAppearance() end end
function GM:OnCharacterSkinChanged(ply, old, new, loaded) if SERVER and not loaded then ply:UpdateAppearance() end end
function GM:OnAppearanceOverrideChanged(ply, old, new, loaded) if SERVER and not loaded then ply:UpdateAppearance() end end

if CLIENT then
	function GM:ShouldHidePlayer(ply)
		local flag = ply:RunCharFlag("ShouldHidePlayer")

		if flag != nil then
			return flag
		end

		local characterHidden = ply:CharacterHidden()
		local teamHidden = Team.IsHidden(ply:Team())

		if not characterHidden and not teamHidden then
			return SCOREBOARD_SHOW
		end

		if (lp == ply) or (lp:IsAdmin() and Settings.Get("ShowHiddenCharacters")) or (not characterHidden and lp:Team() == ply:Team()) then
			return SCOREBOARD_HIDDEN
		end

		return SCOREBOARD_SKIP
	end

	netstream.Hook("PostLoadCharacter", function()
		hook.Run("PostLoadCharacter", lp)
	end)
end
