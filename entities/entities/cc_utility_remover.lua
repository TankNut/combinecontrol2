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

	self:NetworkVar("String", 0, "RemovedName")
end

if CLIENT then
	function ENT:Draw()
		BaseClass.Draw(self)

		if lp:EditMode() and self:IsSaved() and #self:GetRemovedName() > 0 then
			render.DrawWorldText(self:LocalToWorld(Vector(0, 0, 8 + self:GetModelRadius())), "Remover: " .. self:GetRemovedName())
		end
	end
else
	function ENT:PostInitData()
		BaseClass.PostInitData(self)

		local ent = self:GetPickedEntity()

		if IsValid(ent) then
			self:SetRemovedName(#ent:GetName() > 0 and string.format("%s (%s)", ent:GetName(), ent:GetClass()) or ent:GetClass())

			ent.Removing = true
			ent:Remove()
		end
	end
end
