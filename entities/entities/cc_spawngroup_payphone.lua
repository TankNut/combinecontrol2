AddCSLuaFile()
DEFINE_BASECLASS("cc_spawngroup")

ENT.Base = "cc_spawngroup"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Spawngroup Terminal (Payphone)"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Spawnpoints"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Model = Model("models/props_trainstation/payphone001a.mdl")

ENT.SpriteOffset = Vector(6, 3.3, 22.4)

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInitCustom(Vector(-9, -9, -36), Vector(9, 9, 38))

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end
