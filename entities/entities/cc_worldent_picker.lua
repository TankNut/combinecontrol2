DEFINE_BASECLASS("cc_worldent")
AddCSLuaFile()

ENT.Base = "cc_worldent"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Physical = false

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
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Entity", "PickedEntity")
	self:NetworkVar("Vector", "TraceHit")
end

function ENT:Initialize()
	self:SetModel(self.Model)

	if CLIENT then
		local mins, maxs = self:GetRenderBounds()

		self:SetRenderBounds(mins, maxs + Vector(128, 0, 0))
	else
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

function ENT:IsValidPick(ent)
	return ent:CreatedByMap()
end

function ENT:GetTraceEntity()
	local ent = self:GetTrace().Entity

	if not IsValid(ent) or not self:IsValidPick(ent) then
		return NULL
	end

	return ent
end

function ENT:CanSave()
	local ent = self:GetTraceEntity()

	return IsValid(ent) and self:IsValidPick(ent)
end

if CLIENT then
	function ENT:Draw()
		if self:ShouldDraw() then
			self:DrawModel()
		end
	end

	function ENT:DrawTranslucent()
		if not self:ShouldDraw() then
			return
		end

		local mins = self:OBBMins() - Vector(0.1, 0.1, 0.1)
		local maxs = self:OBBMaxs() + Vector(0.1, 0.1, 0.1)

		render.SetColorMaterial()
		render.DrawBox(self:GetPos(), self:GetAngles(), mins, maxs, ColorAlpha(self.Color, 50), true)

		if self:IsSaved() then
			local ent = self:GetPickedEntity()

			render.DrawLine(self:WorldSpaceCenter(), self:GetTraceHit(), self.Color, true)

			if IsValid(ent) then
				render.DrawWireframeBox(ent:GetPos(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs(), self.Color, true)
			end
		else
			local tr = self:GetTrace()
			local ent = tr.Entity

			render.DrawLine(tr.StartPos, tr.HitPos, self.Color, true)

			if IsValid(ent) and self:IsValidPick(ent) then
				render.DrawWireframeBox(ent:GetPos(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs(), self.Color, true)
			end
		end
	end
else
	function ENT:PreSaveEntity()
		self:SetRoll(0)
	end

	function ENT:PostInitData()
		BaseClass.PostInitData(self)

		local ent = self:GetTraceEntity()

		if IsValid(ent) then
			self:SetPickedEntity(ent)
			self:SetTraceHit(self:GetTrace().HitPos)

			self:OnEntityPicked(ent)
		end
	end

	function ENT:OnEntityPicked(ent)
	end
end
