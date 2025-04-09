module("Ambience", package.seeall)

Songs = {}

MusicChannel  = MusicChannel or nil
MusicVolume   = MusicVolume or nil
MusicEndTime  = MusicEndTime or nil
MusicPriority = MusicPriority or AMBIENCE_GLOBAL

EffectChannel  = EffectChannel or nil
EffectVolume   = EffectVolume or nil
EffectEndTime  = EffectEndTime or nil
EffectPriority = EffectPriority or AMBIENCE_GLOBAL

local logger = log.Create("ambience")

local function getVolume(key)
	return math.Remap(Settings.Get(key), 0, 200, 0, 2)
end

function AddSong(type, name, path)
	table.insert(Songs, {
		Type = type,
		Name = name,
		Path = path,
		Length = math.Round(SoundDuration(path))
	})
end

function LogEvent(hint, source, command)
	Log.WriteHint(hint)

	Chat.Receive("CONSOLE", table.concat({
		"<c=white>-- " .. hint .. " --</c>",
		"\tFrom: " .. source,
		"\tStop: " .. command
	}, "\n"))
end

function CreateChannel(path, cb)
	local soundFunction = file.Exists(path, "GAME") and sound.PlayFile or sound.PlayURL

	soundFunction(path, "mono noplay", function(channel, errID, errName)
		if not IsValid(channel) then
			Chat.Receive("CONSOLE", string.format("Failed to play: %s (%s)", path, errName))

			return
		end

		cb(channel)
	end)
end

function PlayMusic(priority, path, volume, source)
	if MusicPriority > priority then
		return
	end

-- TODO: Implement fade-out if one track is played over another.
	StopMusic()
	CreateChannel(path, function(channel)
		channel:SetVolume((volume or 1) * getVolume("PlayMusicVolume"))
		channel:Play()

		MusicChannel = channel
		MusicVolume = volume or 1
		MusicEndTime = CurTime() + channel:GetLength()
		MusicPriority = priority

		LogEvent("Played Music: " .. path, source, "rp_stopmusic")
	end)
end

function StopMusic(priority)
	logger:Debug("Clearing music channel")

	if IsValid(MusicChannel) then
		if priority and MusicPriority > priority then
			return
		end

		MusicChannel:Stop()
	end

	MusicChannel = nil
	MusicVolume = nil
	MusicEndTime = nil
	MusicPriority = AMBIENCE_GLOBAL
end

function PlayEffect(priority, path, volume, source)
	if EffectPriority > priority then
		return
	end

	StopEffect()
	CreateChannel(path, function(channel)
		channel:SetVolume((volume or 1) * getVolume("PlayEffectVolume"))
		channel:Play()

		EffectChannel = channel
		EffectVolume = volume or 1
		EffectEndTime = CurTime() + channel:GetLength()
		EffectPriority = priority

		LogEvent("Played Effect: " .. path, source, "rp_stopeffect")
	end)
end

function StopEffect(priority)
	logger:Debug("Clearing effect channel")

	if IsValid(EffectChannel) then
		if priority and EffectPriority > priority then
			return
		end

		EffectChannel:Stop()
	end

	EffectChannel = nil
	EffectVolume = nil
	EffectEndTime = nil
	EffectPriority = AMBIENCE_GLOBAL
end

function Think()
	if IsValid(EffectChannel) and (EffectChannel:GetState() == GMOD_CHANNEL_STOPPED or EffectEndTime < CurTime()) then
		StopEffect()
	end

	-- TODO: Implement fade-out for music tracks when they near their conclusion.
	if IsValid(MusicChannel) and (MusicChannel:GetState() == GMOD_CHANNEL_STOPPED or MusicEndTime < CurTime()) then
		StopMusic()
	end
end

function GM:OnPlayMusicVolumeSettingChanged(ply, old, new)
	if IsValid(MusicChannel) then
		local volume = MusicVolume * getVolume("PlayMusicVolume")

		logger:Debug("Updating active music volume: %s", volume)
		MusicChannel:SetVolume(volume)
	end
end

function GM:OnPlayEffectVolumeSettingChanged(ply, old, new)
	if IsValid(EffectChannel) then
		local volume = MusicVolume * getVolume("PlayEffectVolume")

		logger:Debug("Updating active effect volume: %s", volume)
		EffectChannel:SetVolume(volume)
	end
end
