AddCSLuaFile()
DEFINE_BASECLASS("cc_worldent")

ENT.Base = "cc_worldent"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Spawngroup Terminal (Combine)"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Spawnpoints"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Physical = true

ENT.Model = Model("models/props_combine/breenconsole.mdl")

ENT.Sprite = Material("particle/particle_glow_05_addnofog")
ENT.SpriteOffset = Vector(13.9, -5.2, 48.2)

ENT.UseSound = Sound("buttons/lightswitch2.wav")

local validation = {
	validate.Max(32)
}

ENT.Actions = {}
ENT.Actions.SetSpawngroup = {
	Name = "Set Spawngroup",

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return not self:IsSaved() end,

	Validate = function(self, ply, name)
		return validate.Value(name, validation)
	end,

	Client = function(self, ply)
		return true, GUI.Open("Input", "string", "Change Spawngroup", {
			Default = self:GetGroup(),
			Validate = validation,
			Name = "Spawn group"
		})
	end,
	Callback = function(self, ply, name)
		self:SetGroup(string.lower(name))
	end
}

function ENT:Initialize()
	self:SetModel(self.Model)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end

		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("String", "Group")
end

function ENT:CanSave()
	return #self:GetGroup() > 0
end

if CLIENT then
	local bad = Color(255, 0, 0)
	local set = Color(33, 255, 0)
	local unset = Color(255, 223, 127)

	function ENT:GetSpriteColor()
		if not self:IsSaved() or not lp:RunCharFlag("AllowSpawngroups") then
			return bad
		end

		if lp:Spawngroup() == self:GetGroup() then
			return set
		end

		return unset
	end

	function ENT:DrawTranslucent()
		render.SetMaterial(self.Sprite)
		render.DrawSprite(self:LocalToWorld(self.SpriteOffset), 8, 8, self:GetSpriteColor())

		local group = self:GetGroup()

		if #group > 0 and self:ShouldDraw() then
			local _, maxs = self:GetModelBounds()

			render.DrawWorldText(self:LocalToWorld(Vector(0, 0, maxs.z + 5)), group)
		end
	end
else
	function ENT:Use(ply)
		if not self:IsSaved() then
			return
		end

		if not ply:RunCharFlag("AllowSpawngroups") then
			return
		end

		local group = self:GetGroup()

		self:EmitSound(self.UseSound)

		if ply:Spawngroup() == group then
			ply:SetSpawngroup("")
			ply:SendChat("NOTICE", "Your spawnpoint has been reset.")
		else
			ply:SetSpawngroup(group)
			ply:SendChat("NOTICE", "Your spawnpoint has been set to this area.")
		end
	end


	function ENT:GetSaveData()
		return {
			Group = self:GetGroup()
		}
	end

	function ENT:LoadSaveData(data)
		self:SetGroup(data.Group)
	end
end
