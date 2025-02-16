local BaseClass = inherit.Get("item", "base")

ITEM.Internal = true

ITEM.Category = "Container"

ITEM.BaseWeight = 0
ITEM.MaxWeight = 10

GM:Include("sh_triggers.lua")

ITEM.Actions = {}
ITEM.Actions.Open = {
	Priority = 20,

	CanRun = function(self, ply)
		return hook.Run("CanOpenItemContainer", ply, self)
	end,
	Callback = function(self, ply)
		ply:OpenGUI("InventoryPopup", self.Contents.ID)
	end
}

function ITEM:Initialize()
	BaseClass.Initialize(self)

	if SERVER then
		self.Contents = Inventory.Create(nil, INV_ITEM, self.ID, self.ID)
	end
end

function ITEM:CanSearchContents(ply)
	return true
end

function ITEM:GetWeight()
	local weight = self:GetData("BaseWeight", self.BaseWeight) + self:GetData("Weight", self.Weight)

	-- Weight saving applies when worn for equipment, otherwise it always applies
	if #self.EquipmentSlots == 0 or self:IsEquipped() then
		weight = weight * self:GetData("WeightMultiplier", self.WeightMultiplier)
	end

	return weight
end

function ITEM:GetMaxWeight()
	return self:GetData("MaxWeight", self.MaxWeight)
end
