AddCSLuaFile()
DEFINE_BASECLASS("cc_worldent")

ENT.Base = "cc_worldent"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Quick Teleport"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Utilities"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Physical = false

ENT.Model = Model("models/editor/playerstart.mdl")

ENT.MinBounds = Vector(-16, -16, 0)
ENT.MaxBounds = Vector(16, 16, 72)

ENT.Color = Color(200, 60, 255)

EntityCache.Add("worldents_quickteleports", function(ent) return ent:IsType("cc_utility_teleport") end)

local validation = {
	validate.Max(32)
}

ENT.Actions = {}
ENT.Actions.SetTeleport = {
	Name = "Set Teleport ID",

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return not self:IsSaved() end,

	Validate = function(self, ply, name)
		return validate.Value(name, validation)
	end,

	Client = function(self, ply)
		return true, ui.Open("Input", "string", "Set Teleport ID", {
			Default = self:GetTeleportID(),
			Validate = validation,
			Name = "Teleport ID"
		})
	end,
	Callback = function(self, ply, id)
		self:SetTeleportID(id)
	end
}

Action.Add("QuickTeleport", {
	Name = "Admin Utilities\tQuick Teleports",

	Self = true,
	Context = "Admin",

	CanRun = FindMetaTable("Player").IsAdmin,
	SubOptions = function(self)
		local options = {}

		for ent in EntityCache.Iterator("worldents_quickteleports") do
			if not ent:IsSaved() then
				continue
			end

			table.insert(options, {
				Name = ent:GetTeleportID(),
				Value = ent
			})
		end

		table.sort(options, function(left, right)
			return left.Value:GetTeleportID() < right.Value:GetTeleportID()
		end)

		if lp:EditMode() then
			table.insert(options, {
				Name = "Create Quick Teleport...",
				Value = nil
			})
		end

		return options
	end,

	Validate = function(self, ply, ent)
		return IsValid(ent) and ent:IsType("cc_utility_teleport") and ent:IsSaved()
	end,
	Client = function(self, ply, ent)
		if not ent then
			ply:ConCommand("gm_spawnsent cc_utility_teleport")

			return false
		end

		return true, ent
	end,
	Callback = function(self, ply, ent)
		local ang = ent:GetAngles()

		ply:SetPos(ent:GetPos())
		ply:SetEyeAngles(Angle(ply:EyeAngles().p, ang.y, 0))
	end
})

if SERVER then
	function ENT:SpawnFunction(ply, tr, class)
		local ent = BaseClass.SpawnFunction(self, ply, tr, class)

		if not IsValid(ent) then
			return
		end

		ent:SetPos(ply:GetPos())
		ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))

		return ent
	end
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInitCustom(self.MinBounds, self.MaxBounds)

	self:SetSubMaterial(0, "models/shiny")
	self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)

	if SERVER then
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("String", "TeleportID")
end

function ENT:CanSave()
	for ent in EntityCache.Iterator("worldents_quickteleports") do
		if self != ent and self:GetTeleportID() == ent:GetTeleportID() then
			return false
		end
	end

	return #self:GetTeleportID() > 0
end

if CLIENT then
	function ENT:Draw()
		if not self:ShouldDraw() then
			return
		end

		render.SetColorModulation(self.Color:UnpackToVector())
		self:DrawModel()
		render.SetColorModulation(1, 1, 1)
	end

	function ENT:DrawTranslucent()
		if not self:ShouldDraw() then
			return
		end

		local label = "Quick Teleport: " .. (#self:GetTeleportID() > 0 and self:GetTeleportID() or "*INVALID*")

		render.DrawWorldText(self:LocalToWorld(Vector(0, 0, self.MaxBounds.z + 2)), label)
	end
else
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:PreSaveEntity()
		self:UpdateAngles(0, nil, 0)
	end

	function ENT:GetSaveData()
		return {
			TeleportID = self:GetTeleportID()
		}
	end

	function ENT:LoadSaveData(data)
		self:SetTeleportID(data.TeleportID)
	end
end
