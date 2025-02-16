function ITEM:SetItemAppearance(ent)
	ent:SetSkin(self:GetSkin())
	ent:SetColor(self:GetColor())

	local scale = self:GetData("Scale", self.Scale)

	if scale != 1 then
		ent:SetModelScale(scale, 0.0001)
	end
end

function ITEM:GetModel() return self:GetData("Model", self.Model) end
function ITEM:GetSkin() return self:GetData("Skin", self.Skin) end

function ITEM:GetColor() return self:GetData("Color", self.Color) end
function ITEM:GetScale() return self:GetData("Scale", self.Scale) end
