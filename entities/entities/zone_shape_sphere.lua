AddCSLuaFile()

ENT.Base = "zone_shape_base"

function ENT:SetupDataTables()
	self:NetworkVar("Vector", "Position")

	self:NetworkVar("Float", "Radius")
end

local zoneSphere = util.SphereShape()

function ENT:Contains(ply)
	zoneSphere:Set(self:GetPosition(), self:GetRadius())

	return zoneSphere:Contains(ply:EyePos())
end

if CLIENT then
	function ENT:DrawShape()
		local pos = self:GetPosition()
		local radius = self:GetRadius()

		render.SetColorMaterial()
		render.DrawSphere(pos, radius, 20, 20, self.Color)
		render.DrawSphere(pos, -radius, 20, 20, self.Color)
		render.DrawWireframeSphere(pos, radius, 20, 20, self.OutlineColor)
	end
else
	function ENT:Setup(pos, radius)
		self:SetPosition(pos)
		self:SetRadius(radius)
	end
end
