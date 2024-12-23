DEFINE_BASECLASS("item_base")

ITEM.BaseWeight = 0
ITEM.MaxWeight = 10

ITEM.Actions = {}

ITEM.Actions.Open = {
	Categories = {Rightclick = true},
	Priority = 20,

	CanRun = function(self, ply)
		return self:IsOwner(ply)
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

function ITEM:OnRemove(unloading)
	BaseClass.OnRemove(self, unloading)

	if SERVER then
		self.Contents:Remove()
	end
end

function ITEM:OnMove(old, new, loading)
	BaseClass.OnMove(self, old, new, loading)

	if SERVER then
		self.Contents:UpdateReceivers()
	end
end

function ITEM:GetWeight()
	local weight = self:GetData("BaseWeight", self.BaseWeight) + self:GetData("Weight", self.Weight)

	if self:IsEquipped() then
		weight = weight * self:GetData("WeightMultiplier", self.WeightMultiplier)
	end

	return weight
end

function ITEM:GetMaxWeight() return self:GetData("MaxWeight", self.MaxWeight) end
