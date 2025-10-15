local BaseClass = inherit.Get("item", "base")

ITEM.Internal = true

ITEM.Rarity   = RARITY_COMMON
ITEM.Category = "Radio"

ITEM.Model = Model("models/Items/combine_rifle_cartridge01.mdl")

ITEM.EquipmentSlots = {"radio"}

ITEM.EquipTime   = 0.25
ITEM.UnequipTime = 0.25

ITEM.Actions = {}

ITEM.CanSetFrequency = false -- Determines whether a radio is restricted to presets
ITEM.CanEncrypt      = false -- Determines whether an encrpytion can be set

ITEM.RadioPresets = {} -- Organization radio channels like CCA_MAIN, NYPD, UNSC, etc

ITEM.RadioGroups     = {} --  Set during configuration; determines who receives a dispatch message
ITEM.ChannelSettings = {} -- Set during configuration; channel-specific settings

ITEM.Encryption = false -- Set during configuration; facilitated encrpyted traffic between radios
ITEM.Channel    = 1     -- Set during configuration; active index in ChannelSettings

ITEM.Actions.OpenGUI = {
	Name       = "Configure Radio",
	ClientOnly = true,
	Priority   = ITEM_ACTION_OPTION - 1,

	CanRun = function(self, ply) return not self:IsLocked() end,
	Client = function(self, ply) end -- TODO: Call ui.Open("Radio")
}

ITEM.Actions.ToggleLocked = {
	Name     = "ADMIN: Toggle Locked",
	Priority = ITEM_ACTION_OPTION - 2,

	CanRun   = function(self, ply) return ply:IsAdmin() end,
	Callback = function(self, ply) self:ToggleLocked(ply) end
}

function ITEM:GetDescription()
	local description = BaseClass.GetDescription(self)

	if self:IsLocked() then
		description = description .. "\n\n<col=red>This radio's configuration is locked.</col>"
	end

	return description
end

function ITEM:IsLocked()
	return self:GetData("Locked", false)
end

function ITEM:ToggleLocked(ply)
	local locked = not self:IsLocked()

	self:SetData("Locked", locked)

	ply:SendChat("NOTICE", string.format("This radio has been %s!", locked and "locked" or "unlocked"))
end

function ITEM:SetEncryption(encryption)
	self.Encryption = encryption
end

function ITEM:SetChannel(channel)
	self.Channel = channel
end
