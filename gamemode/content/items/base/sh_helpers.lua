function ITEM:IsTemporaryItem()
	return self.ID < 0
end

function ITEM:SetItemAppearance(ent)
	ent:SetSkin(self:GetSkin())

	local scale = self:GetData("Scale", self.Scale)

	if scale != 1 then
		ent:SetModelScale(scale, 0.0001)
	end
end
