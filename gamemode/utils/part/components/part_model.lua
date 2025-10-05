local BaseClass = inherit.Get("part", "base")
local PART = {}

function PART:Initialize(outfit, name, data)
	BaseClass.Initialize(self, outfit, name, data)

	self.Model = data.Model or "models/error.mdl"

	self.ModelData = {}

	for field in pairs(APPLYMODEL_FIELDS) do
		if field == "Model" then
			continue
		end

		self.ModelData[field] = data[field]
	end

	self.Bonemerge = data.Bonemerge or false

	self:CreateModel()
end

function PART:CreateModel()
	SafeRemoveEntity(self.CSEnt)

	self.CSEnt = ClientsideModel(self.Model)
	self.CSEnt:ApplyModel(self.ModelData)

	self:UpdateMaterial()
	self:UpdateNoDraw()
	self:UpdateBonemerge()
	self:UpdatePosition()

	return self.CSEnt
end

function PART:Remove()
	SafeRemoveEntity(self.CSEnt)
end

function PART:UpdateMaterial()
	local fallback = isstring(self.ModelData.Materials) and self.ModelData.Materials or ""
	local parent = self:GetEntity():GetMaterial()

	if parent != "" then
		self.CSEnt:SetMaterial(parent)
	else
		self.CSEnt:SetMaterial(fallback)
	end
end

function PART:UpdateNoDraw()
	local ent = self.CSEnt
	local should = self:ShouldHide()

	ent:SetNoDraw(should)

	local owner = self:GetEntity()
	local hideShadow = should or owner:IsEffectActive(EF_NOSHADOW)

	if owner == lp and not owner:ShouldDrawLocalPlayer() then
		hideShadow = true
	end

	if hideShadow then
		ent:DestroyShadow()
	else
		ent:CreateShadow()
	end
end

function PART:UpdateBonemerge()
	if not self.Bonemerge then
		return
	end

	local ent = self.CSEnt
	local parent = self:GetEntity()

	if ent:GetParent() != parent then
		ent:SetParent(parent)
		ent:SetLocalPos(vector_origin)

		if not ent:IsEffectActive(EF_BONEMERGE) then
			ent:AddEffects(EF_BONEMERGE)
		end
	end
end

function PART:UpdatePosition()
	if self.Bonemerge then
		return
	end
end

function PART:Think()
	if not IsValid(self.CSEnt) then
		self:CreateModel()
	else
		self:UpdateMaterial()
		self:UpdateNoDraw()
		self:UpdateBonemerge()
		self:UpdatePosition()
	end
end

function PART:Draw(renderMode)
	if not renderMode then
		self.CSEnt:DrawModel()
	end
end

inherit.Register("part", "model", PART, "base")
