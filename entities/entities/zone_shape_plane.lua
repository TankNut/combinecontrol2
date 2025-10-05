AddCSLuaFile()

ENT.Base = "zone_shape_base"

function ENT:SetupDataTables()
	self:NetworkVar("Vector", "Position")
	self:NetworkVar("Vector", "Normal")
end

local zonePlane = util.PlaneShape()

function ENT:Contains(ply)
	zonePlane:FromPoint(self:GetPosition(), self:GetNormal())

	return zonePlane:Contains(ply:EyePos())
end

if CLIENT then
	function ENT:DrawShape()
		local pos = self:GetPosition()
		local normal = self:GetNormal()

		render.DrawLine(pos, pos + normal * 250, self.OutlineColor)
		render.DrawQuadEasy(pos, normal, MAX_LENGTH_AXIS, MAX_LENGTH_AXIS, self.OutlineColor)
		render.DrawQuadEasy(pos, -normal, MAX_LENGTH_AXIS, MAX_LENGTH_AXIS, self.OutlineColor)

		render.SetColorMaterial()
		render.DrawQuadEasy(pos, normal, MAX_LENGTH_AXIS, MAX_LENGTH_AXIS, self.Color)
		render.DrawQuadEasy(pos, -normal, MAX_LENGTH_AXIS, MAX_LENGTH_AXIS, self.Color)
	end
else
	function ENT:Setup(pos, normal)
		self:SetPosition(pos)
		self:SetNormal(normal)
	end
end
