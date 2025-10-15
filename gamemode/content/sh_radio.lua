module("Radio", package.seeall)

Lookup = {}

local PLAYER = FindMetaTable("Player")

function AddPreset(group, name)
	return table.insert(Lookup, {
		Freq = #Lookup + 1000,
		Group = group,
		Name = name
	})
end

function GetPreset(preset)
	return Lookup[preset]
end

function PLAYER:CanHearRadio(frequency)
	local radio = self:GetEquipment("radio")

	if not radio then
		return false
	end

	local setting = radio.ChannelSettings[frequency]

	if not setting then
		return false
	end

	-- TODO: Add encryption check

	return setting.Enabled and true or false
end

function PLAYER:HasRadioGroup(group)
	local radio = self:GetEquipment("radio")

	if not radio then
		return false
	end

	return radio.RadioGroups[group] and true or false
end
