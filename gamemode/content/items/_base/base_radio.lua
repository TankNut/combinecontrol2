local BaseClass = inherit.Get("item", "base")

ITEM.Internal = true

ITEM.Category = "Radio"

ITEM.Model = Model("models/Items/combine_rifle_cartridge01.mdl")

ITEM.EquipmentSlots = {"radio"}

ITEM.EquipTime   = 0.5
ITEM.UnequipTime = 0.5

ITEM.IconAngle = Angle(30, -60, -10)
ITEM.IconFOV   = 11

ITEM.Actions = {}

ITEM.CanSetFrequency = false -- Can frequencies between 1-999 MHz can be set
ITEM.CanEncrypt      = false -- Can an encrpytion can be set
ITEM.MaxChannels     = 1     -- How many channels can be tuned into simultaneously
ITEM.RadioPresets    = {}    -- Which, if any, preset radio channels can be set

ItemDataFunc("ChannelSettings", {}) -- Set during configuration; channel-specific settings
ItemDataFunc("RadioGroups",     {}) -- Set during configuration; what dispatch messages are received
ItemDataFunc("ActiveChannel",    0) -- Set during configuration; active index in ChannelSettings

ITEM.Actions.OpenGUI = {
	Name       = "Configure Radio",
	ClientOnly = true,
	Priority   = ITEM_ACTION_OPTION - 1,

	CanRun = function(self, ply) return not self:IsLocked() end,
	Client = function(self, ply) self:OpenGUI() end
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

function ITEM:HasRadioGroup(group)
	return self:GetRadioGroups()[group] and true or false
end

function ITEM:IsLocked()
	return self:GetData("Locked", false)
end

function ITEM:ToggleLocked(ply)
	local locked = not self:IsLocked()

	self:SetData("Locked", locked)

	ply:SendChat("NOTICE", string.format("This radio has been %s!", locked and "locked" or "unlocked"))
end

if CLIENT then
	function ITEM:OpenGUI()
		ui.Open("Radio", {
			ItemID          = self.ID,
			CanSetFrequency = self.CanSetFrequency,
			CanEncrypt      = self.CanEncrypt,
			MaxChannels     = self.MaxChannels,
			RadioPresets    = self.RadioPresets,
			ActiveChannel   = self:GetActiveChannel(),
			Settings        = self:GetChannelSettings(),
			Options         = {"Enabled", "Speaker", "Frequency", "Preset", "Encryption"}
		})
	end
end
