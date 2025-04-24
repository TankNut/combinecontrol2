module("Voicelines", package.seeall)

Groups = {}

local PLAYER = FindMetaTable("Player")

function Add(name, data)
	Groups[name] = {
		ID = name,
		Name = data.Name,
		CanAccess = data.CanAccess or function(ply) return true end,
		Options = data.Options
	}
end

function Get(name)
	return Groups[name]
end

function PLAYER:CanPlayVoicelines(name)
	return hook.Run("CanPlayVoicelines", self, name)
end

function GM:CanPlayVoicelines(ply, name)
	if not ply:CanAct() or not ply:Alive() then
		return false
	end

	if name and not Get(name).CanAccess(ply) then
		return false
	end

	if ply.NextVoicelineTime and ply.NextVoicelineTime > CurTime() then
		return false
	end

	return true
end

if SERVER then
	function PLAYER:PlayVoiceline(name, index, db)
		hook.Run("PlayVoiceline", self, name, index, db)
	end

	function GM:PlayVoiceline(ply, name, index, db)
		if not db then
			db = 75
		end

		local voiceline = Get(name).Options[index]

		if not voiceline then
			return
		end

		local sound = voiceline.Sound

		-- TODO: "tables" -> Old CC1 sound tables.
		if isstring(sound) and string.match(sound, ".-%.wav") then
			ply:EmitSound(sound, db)
		else
			EmitSentence(sound, ply:GetPos(), ply:EntIndex(), CHAN_AUTO, 1, db, 0, 100)
		end

		Chat.Send("CONSOLE", ply:VisibleRPName() .. " played voiceline: \"" .. voiceline.Name .. "\"", Chat.GetTargets(ply:EyePos(), 300, 300, false))

		if voiceline.Chat then
			Chat.Parse(ply, isstring(voiceline.Chat) and voiceline.Chat or voiceline.Name)
		end

		ply.NextVoicelineTime = CurTime() + Config.Get("VoicelineDelay")
	end
end
