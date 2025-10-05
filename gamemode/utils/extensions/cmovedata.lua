local CMoveData = FindMetaTable("CMoveData")

function CMoveData:LimitSpeed(min)
	if self:GetMaxClientSpeed() < min then
		return
	end

	self:SetMaxSpeed(min)
	self:SetMaxClientSpeed(min)
end
