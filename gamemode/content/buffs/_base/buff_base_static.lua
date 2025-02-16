local BaseClass = inherit.Get("buff", "base")

function BUFF:Initialize(data)
	BaseClass.Initialize(self, data)

	self:AddStacks(1)
end

function BUFF:OnDuplicate(data)
	self:AddStacks(1)
end
