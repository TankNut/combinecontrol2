DEFINE_BASECLASS("cc_worldent_picker")
AddCSLuaFile()

ENT.Base = "cc_worldent_picker"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Entity Remover"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Utilities"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Color = Color(255, 0, 0)

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("String", "RemovedName")

	self:NetworkVar("Bool", "DidRemove")

	self:NetworkVar("Vector", "RemovedPos")
	self:NetworkVar("Angle", "RemovedAngles")

	self:NetworkVar("Vector", "RemovedMins")
	self:NetworkVar("Vector", "RemovedMaxs")
end

if CLIENT then
	function ENT:GetLabel()
		local name = self:GetRemovedName()

		if #name > 0 then
			return "Remover: " .. name
		else
			return "Remover"
		end
	end

	function ENT:DrawTranslucent()
		BaseClass.DrawTranslucent(self)

		if self:ShouldDraw() then
			render.DrawWorldText(self:LocalToWorld(Vector(0, 0, self:GetModelRadius() + 8)), self:GetLabel())

			if self:GetDidRemove() then
				render.DrawWireframeBox(self:GetRemovedPos(), self:GetRemovedAngles(), self:GetRemovedMins(), self:GetRemovedMaxs(), self.Color, true)
			end
		end
	end
else
	function ENT:OnEntityPicked(ent)
		self:SetDidRemove(true)

		self:SetRemovedName(#ent:GetName() > 0 and string.format("%s (%s)", ent:GetName(), ent:GetClass()) or ent:GetClass())

		self:SetRemovedPos(ent:GetPos())
		self:SetRemovedAngles(ent:GetAngles())

		self:SetRemovedMins(ent:OBBMins())
		self:SetRemovedMaxs(ent:OBBMaxs())

		ent:Remove()
	end
end
