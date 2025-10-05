local PART = {}

function PART:Initialize(outfit, name, data)
	self.Outfit = outfit
	self.Name = name

	self.Bone = data.Bone or ""

	self.Position = data.Position or Vector()
	self.Angles = data.Angle or Angle()

	self.PositionOffset = data.PositionOffset or Vector()
	self.AngleOffset = data.AngleOffset or Angle()

	self.WorldMatrix = Matrix()
	self.LastWorldMatrix = 0

	self.Hidden = false
end

function PART:Think()
end

function PART:Remove()
end

function PART:GetEntity()
	return self.Outfit.Entity
end

function PART:ShouldHide()
	local ent = self:GetEntity()

	if ent:IsDormant() or ent:GetNoDraw() then
		return true
	end

	if (ent:IsPlayer() or ent:IsNPC()) and not ent:Alive() then
		return true
	end

	return false
end

function PART:GetRenderPos()
	local matrix = self:GetWorldMatrix()

	return matrix:GetTranslation(), matrix:GetAngles()
end

function PART:GetWorldMatrix()
	if self.LastWorldMatrix != FrameNumber() then
		self:BuildWorldMatrix()
	end

	return self.WorldMatrix
end

local boneMatrix = Matrix()

function PART:GetBoneMatrix()
	local bonePos, boneAng = part.GetBone(self:GetEntity(), self.Bone)

	boneMatrix:SetTranslation(bonePos)
	boneMatrix:SetAngles(boneAng)

	return boneMatrix
end

function PART:BuildWorldMatrix()
	self.WorldMatrix:Identity()
	self.WorldMatrix:SetTranslation(self.Position)
	self.WorldMatrix:SetAngles(self.Angles)

	self.WorldMatrix = self:GetBoneMatrix() * self.WorldMatrix

	self.WorldMatrix:Translate(self.PositionOffset)
	self.WorldMatrix:Rotate(self.AngleOffset)

	self.LastWorldMatrix = FrameNumber()
end

local r = Color("red")
local g = Color("lime")
local b = Color("blue")

function PART:Draw(renderMode)
	if renderMode and self:ShouldHide() then
		return
	end

	local pos, ang = self:GetRenderPos()

	render.DrawLine(pos, pos + ang:Forward() * 5, r, true)
	render.DrawLine(pos, pos - ang:Right() * 5, g, true)
	render.DrawLine(pos, pos + ang:Up() * 5, b, true)
end

inherit.Register("part", "base", PART)
