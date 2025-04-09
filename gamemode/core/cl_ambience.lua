module("Ambience", package.seeall)

Songs = {}

MusicChannel = MusicChannel or nil
MusicEndTime = MusicEndTime or nil
MusicPriority = MusicPriority or AMBIENCE_GLOBAL

EffectChannel = EffectChannel or nil
EffectEndTime = EffectEndTime or nil
EffectPriority = EffectPriority or AMBIENCE_GLOBAL

local logger = log.Create("ambience")

function AddSong(type, name, path)
	table.insert(Songs, {
		Type = type,
		Name = name,
		Path = path,
		Length = math.Round(SoundDuration(path))
	})
end

function CreateChannel(path, cb)
	local soundFunction = file.Exists(path, "GAME") and sound.PlayFile or sound.PlayURL

	soundFunction(path, "mono noplay", function(channel, errID, errName)
		if not IsValid(channel) then
			print("FAILED TO DO IT! ", errID, errName)

			return
		end

		cb(channel)
	end)
end

function PlayMusic(priority, source, volume, path)
	if MusicPriority > priority then
		return
	end

	-- TODO: Implement fade-out if one track is played over another.
	StopMusic()
	CreateChannel(path, function(channel)
		channel:SetVolume(volume or 0)
		channel:Play()

		MusicChannel = channel
		MusicEndTime = CurTime() + channel:GetLength()
		MusicPriority = priority

		print(string.format("%s has played a music (%s), you can stop this with rp_stopmusic", source, path))
	end)
end

function StopMusic()
	logger:Debug("Clearing music channel")

	if IsValid(MusicChannel) then
		MusicChannel:Stop()
	end

	MusicChannel = nil
	MusicEndTime = nil
	MusicPriority = AMBIENCE_GLOBAL
end

function PlayEffect(priority, source, volume, path)
	if EffectPriority > priority then
		return
	end

	StopEffect()
	CreateChannel(path, function(channel)
		channel:SetVolume(volume or 0)
		channel:Play()

		EffectChannel = channel
		EffectEndTime = CurTime() + channel:GetLength()
		EffectPriority = priority

		print(string.format("%s has played an effect (%s), you can stop this with rp_stopeffect", source, path))
	end)
end

function StopEffect()
	logger:Debug("Clearing effect channel")

	if IsValid(EffectChannel) then
		EffectChannel:Stop()
	end

	EffectChannel = nil
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
