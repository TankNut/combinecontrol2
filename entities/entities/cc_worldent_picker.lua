DEFINE_BASECLASS("cc_worldent")
AddCSLuaFile()

ENT.Base = "cc_worldent"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model = Model("models/hunter/blocks/cube025x025x025.mdl")
ENT.Color = Color(255, 255, 255)

if SERVER then
	function ENT:SpawnFunction(ply, tr, class)
		local ent = BaseClass.SpawnFunction(self, ply, tr, class)

		if not IsValid(ent) then
			return
		end

		ent:SetPos(ply:EyePos())
		ent:SetAngles(ply:EyeAngles())

		return ent
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", "EntityID")
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Entity", 0, "PickedEntity")
	self:SetPickedEntity(NULL)
end

function ENT:Initialize()
	self:SetModel(self.Model)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:SetMaterial("models/shiny")
end

function ENT:GetTrace()
	return util.TraceLine({
		start = self:WorldSpaceCenter(),
		endpos = self:WorldSpaceCenter() + (self:GetForward() * 128),
		filter = {self}
	})
end

function ENT:CanSave()
	local ent = self:GetTrace().Entity

	if not IsValid(ent) or ent:IsPlayer() or string.StartsWith(ent:GetClass(), "cc_") then
		return false
	end

	return true
end

if CLIENT then
	function ENT:Draw()
		if lp:EditMode() then
			self:DrawModel()

			local mins = self:OBBMins() - Vector(0.1, 0.1, 0.1)
			local maxs = self:OBBMaxs() + Vector(0.1, 0.1, 0.1)

			render.SetColorMaterial()
			render.DrawBox(self:GetPos(), self:GetAngles(), mins, maxs, ColorAlpha(self.Color, 50), true)

			local tr = self:GetTrace()

			render.DrawLine(tr.StartPos, tr.HitPos, self.Color, true)

			local ent = tr.Entity

			if self:IsSaved() then
				ent = self:GetPickedEntity()
			end

			if IsValid(ent) and not ent:IsPlayer() then
				render.DrawWireframeBox(ent:GetPos(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs(), self.Color, not edit)
			end
		end
	end
else
	function ENT:PostInitData()
		BaseClass.PostInitData(self)

		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

		local ent = self:GetTrace().Entity

		if not IsValid(ent) or ent:IsPlayer() then
			return
		end

		self:SetPickedEntity(ent)
	end
end
