AddCSLuaFile()

ENT.Base = "zone_shape_base"

function ENT:SetupDataTables()
	self:NetworkVar("Vector", "Mins")
	self:NetworkVar("Vector", "Maxs")
end

local zoneHull = util.BoxShape()

function ENT:Contains(ply)
	zoneHull:FromBounds(self:GetMins(), self:GetMaxs())

	return zoneHull:Contains(ply:EyePos())
end

if CLIENT then
	function ENT:DrawShape()
		local mins = self:GetMins()
		local maxs = self:GetMaxs()

		render.SetColorMaterial()
		render.DrawBox(vector_origin, angle_zero, mins, maxs, self.Color)
		render.DrawBox(vector_origin, angle_zero, maxs, mins, self.Color)
		render.DrawWireframeBox(vector_origin, angle_zero, mins, maxs, self.OutlineColor)
	end
else
	function ENT:Setup(mins, maxs)
		self:SetMins(mins)
		self:SetMaxs(maxs)
	end
end
