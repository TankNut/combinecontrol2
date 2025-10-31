AddCSLuaFile()
DEFINE_BASECLASS("cc_worldent")

ENT.Base = "cc_worldent"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Container"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Interactables"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Physical = true

ENT.Model = Model("models/Items/ammocrate_smg1.mdl")

ENT.Actions = {}
ENT.Actions.SetLockType = {
	Name = "Set Lock Type",

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return not self:IsSaved() end,

	SubOptions = {
		{Name = "Public", Value = CONTAINER_PUBLIC},
		{Name = "Key", Value = CONTAINER_KEY},
		{Name = "Admin-only", Value = CONTAINER_ADMIN}
	},
	Validate = function(self, ply, lock)
		return validate.Value(lock, validate.InList({CONTAINER_PUBLIC, CONTAINER_KEY, CONTAINER_ADMIN}))
	end,

	Callback = function(self, ply, lock)
		self:SetLockType(lock)
	end
}

local validation = {
	validate.Max(32)
}

ENT.Actions.SetID = {
	Name = "Set Container ID",

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return not self:IsSaved() end,

	Validate = function(self, ply, name)
		return validate.Value(name, validation)
	end,

	Client = function(self, ply)
		return true, ui.Open("Input", "string", "Change container ID", {
			Default = self:GetContainerID(),
			Validate = validation,
			Name = "Container ID"
		})
	end,
	Callback = function(self, ply, id)
		for ent in EntityCache.Iterator("containers") do
			if ent != self and ent:GetContainerID() == id then
				return false, "This Container ID is already in use on this map!"
			end
		end

		self:SetContainerID(string.lower(id))
	end
}

ENT.Actions.AdminAccess = {
	Name = "Admin Actions/Access",
	Priority = 1,

	Access = ACTION_ADMIN,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return self:IsSaved() and not self:GetOpen() end,

	Callback = function(self, ply)
		self:ShowInventory(ply)
	end
}

ENT.Actions.AdminOpen = {
	Name = "Admin Actions/Open",

	Access = ACTION_ADMIN,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return self:IsSaved() and not self:GetOpen() end,

	Callback = function(self, ply)
		self:SetOpen(true)
		self:Open()
	end
}

ENT.Actions.Open = {
	Name = "Open",
	Priority = 2,

	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return self:IsSaved() and not self:GetOpen() end,

	Callback = function(self, ply)
		if self:HasAccess(ply) then
			self:SetOpen(true)
			self:Open()
		else
			ply:SendChat("ERROR", "The container doesn't budge")
		end
	end
}

ENT.Actions.Close = {
	Name = "Close",
	Priority = 2,

	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return self:IsSaved() and self:GetOpen() end,

	Callback = function(self, ply, lock)
		self:SetOpen(false)
	end
}

EntityCache.Add("containers", function(ent) return ent:IsType("cc_container") end)

function ENT:Initialize()
	self:SetModel(self.Model)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:ResetSequence("close")
		self:SetCycle(1)

		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("String", "ContainerID")

	self:NetworkVar("Int", "InventoryID")
	self:NetworkVar("Int", "LockType")

	self:NetworkVar("Float", "OpenTime")

	self:NetworkVar("Bool", "Open")
end

function ENT:Think()
	self:NextThink(CurTime())

	if SERVER then
		local openTime = self:GetOpenTime()

		if openTime != 0 and openTime <= CurTime() and not self:GetOpen() then
			self:EmitSound("AmmoCrate.Close")

			self:ResetSequence("close")
			self:SetOpenTime(0)
		end
	end

	return true
end

function ENT:GetInventory()
	return Inventory.Get(self:GetInventoryID())
end

function ENT:CanSave()
	return #self:GetContainerID() > 0
end

function ENT:CanAccessInventory(ply)
	if self:GetOpen() then
		return true
	end

	if CLIENT then
		return Inventory.Get(self:GetInventoryID())
	else
		return self:GetInventory().Listeners[ply]
	end
end

if CLIENT then
	local map = {
		[CONTAINER_PUBLIC] = "Public",
		[CONTAINER_KEY] = "Key",
		[CONTAINER_ADMIN] = "Admin-Only"
	}

	function ENT:DrawTranslucent()
		if not lp:EditMode() then
			return
		end

		local id = self:GetContainerID()

		if #id == 0 then
			id = "*INVALID*"
		end

		render.DrawWorldText(self:LocalToWorld(Vector(0, 0, 23)), "ID: " .. id)
		render.DrawWorldText(self:LocalToWorld(Vector(0, 0, 20)), "Lock Type: " .. map[self:GetLockType()])
	end
else
	function ENT:HasAccess(ply)
		if self:GetOpen() then
			return true
		end

		local lockType = self:GetLockType()

		if lockType == CONTAINER_PUBLIC then
			return true
		elseif lockType == CONTAINER_KEY then
			return ply:HasKey(KEY_CONTAINER, self:GetContainerID())
		elseif lockType == CONTAINER_ADMIN then
			return ply:IsAdmin()
		end

		return false
	end

	function ENT:Use(ply)
		if self:HasAccess(ply) then
			self:ShowInventory(ply)
		else
			ply:SendChat("ERROR", "The container doesn't budge")
		end
	end

	function ENT:ShowInventory(ply)
		local inventory = self:GetInventory()
		inventory:AddListener(ply, LISTENER_ENTITY)

		ply:OpenGUI("InventoryPopup", inventory.ID)

		if not self:GetOpen() then
			self:Open()
		end
	end

	function ENT:Open()
		self:EmitSound("AmmoCrate.Open")

		self:ResetSequence("open")
		self:SetOpenTime(CurTime() + self:SequenceDuration() + 0.5)
	end

	function ENT:GetSaveData()
		return {
			ID = self:GetContainerID(),
			Lock = self:GetLockType()
		}
	end

	function ENT:LoadSaveData(data)
		self:SetContainerID(data.ID)
		self:SetLockType(data.Lock)
	end

	function ENT:PostInitData()
		BaseClass.PostInitData(self)

		Inventory.Create(nil, INV_ENTITY, self:GetContainerID(), self:EntIndex())
	end

	function ENT:OnRemove()
		local inventory = self:GetInventory()

		if inventory then
			inventory:Remove()
		end
	end
end
