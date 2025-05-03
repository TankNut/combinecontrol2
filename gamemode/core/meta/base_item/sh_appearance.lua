function ITEM:SetItemAppearance(ent)
	ent:SetSkin(self:GetSkin())
	ent:SetColor(self:GetColor())

	local scale = self:GetData("Scale", self.Scale)

	if scale != 1 then
		ent:SetModelScale(scale, 0.0001)
	end

	ent:SetMaterial(self:GetMaterial())
end

ItemDataFunc("Model")
ItemDataFunc("Skin")

ItemDataFunc("Color")
ItemDataFunc("Scale")

ItemDataFunc("Material")
