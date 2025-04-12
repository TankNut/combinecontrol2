AddCSLuaFile()
DEFINE_BASECLASS("cc_worldent")

ENT.Base = "cc_worldent"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Fallback Spawn"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Spawnpoints"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Physical = false

ENT.Model = Model("models/editor/playerstart.mdl")

ENT.MinBounds = Vector(-16, -16, 0)
ENT.MaxBounds = Vector(16, 16, 72)

ENT.Mode = SPAWN_FALLBACK
ENT.BadColor = Color(255, 0, 0)

if SERVER then
	EntityCache.Add("spawns", function(ent) return ent:IsType("cc_spawnpoint") end)
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInitCustom(self.MinBounds, self.MaxBounds)

	self:SetSubMaterial(0, "models/shiny")

	if SERVER then
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end

function ENT:GetSpawnTrace()
	if self.LastTrace and self.LastTrace != FrameNumber() then
		self.SpawnTrace = nil
	end

	if not self.SpawnTrace then
		local pos = self:GetPos()

		self.LastTrace = FrameNumber()
		self.SpawnTrace = util.TraceHull({
			start = pos,
			endpos = pos,
			mask = MASK_PLAYERSOLID,
			collisiongroup = COLLISION_GROUP_WORLD,
			mins = self.MinBounds,
			maxs = self.MaxBounds,
			filter = self
		})
	end

	return self.SpawnTrace
end

function ENT:IsBlocked()
	return self:GetSpawnTrace().Hit
end

function ENT:IsOccupied()
	local pos = self:GetPos()

	for _, v in ipairs(ents.FindInBox(pos + self.MinBounds, pos + self.MaxBounds)) do
		if v:IsPlayer() then
			return true
		end
	end

	return false
end

if CLIENT then
	local default = Color(0, 255, 0)

	function ENT:GetModelColor()
		if self:IsBlocked() then
			return self.BadColor
		end

		return default
	end

	function ENT:GetLabel()
		return "Fallback"
	end

	function ENT:DrawSpawnpoint()
		render.SetColorModulation(self:GetModelColor():UnpackToVector())
		self:DrawModel()
		render.SetColorModulation(1, 1, 1)
	end

	function ENT:Draw()
		if self:ShouldDraw() or self:IsBlocked() then
			self:DrawSpawnpoint()
		end

		if halo.RenderedEntity() != self and self:IsBlocked() then
			render.DrawWireframeBox(self:GetPos(), angle_zero, self.MinBounds, self.MaxBounds, self.BadColor, true)
		end
	end

	function ENT:DrawTranslucent()
		if self:IsSaved() and lp:HasToolOut() then
			render.SetBlend(0.2)

			self:DrawSpawnpoint()

			render.SetBlend(1)
		end

		if self:ShouldDraw() then
			render.DrawWorldText(self:LocalToWorld(Vector(0, 0, self.MaxBounds.z + 2)), self:GetLabel())
		end
	end
else
	function ENT:PreSaveEntity()
		self:UpdateAngles(0, nil, 0)
	end
end
