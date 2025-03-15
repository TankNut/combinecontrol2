AddCSLuaFile()
DEFINE_BASECLASS("cc_spawngroup")

ENT.Base = "cc_spawngroup"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Spawngroup Terminal (Panel)"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Spawnpoints"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Model = Model("models/props_lab/tpswitch.mdl")

ENT.SpriteOffset = Vector(4, 1, 2.9)

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInitCustom(Vector(-5, -10.5, -51), Vector(6.5, 10.5, 18))

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end
