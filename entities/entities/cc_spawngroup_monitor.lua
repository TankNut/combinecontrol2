AddCSLuaFile()
DEFINE_BASECLASS("cc_spawngroup")

ENT.Base = "cc_spawngroup"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Spawngroup Terminal (Monitor)"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Spawnpoints"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Model = Model("models/props_lab/monitor02.mdl")

ENT.SpriteOffset = Vector(12.2, 7.5, 4)
