AddCSLuaFile()

ENT.Base = "cc_base_ent"

ENT.AllowPhys = true -- Allow everyone to physgun us

function ENT:Initialize()
	self:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)

	if util.IsValidProp(self:GetModel()) then
		if SERVER then
			self:PhysicsInit(SOLID_VPHYSICS)
		end
	else
		self:PhysicsInitCustom(self:GetModelBounds())
	end

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("String", "ItemName")
	self:NetworkVar("Float", "ItemWeight")

	self:NetworkVar("Int", "Rarity")
end

function ENT:Think()
	if CLIENT then
		return
	end

	if self.Item and self:HasMoved() then
		self:SaveMoved()

		async.Start(self.Item.SaveLocation, self.Item)
	end

	self:NextThink(CurTime() + 30)

	return true
end

function ENT:HasMoved()
	if not self.SavedPos then
		return true
	end

	local pos = self:GetPos()
	local ang = self:GetAngles()

	pos = Vector(math.Round(pos.x, 2), math.Round(pos.y, 2), math.Round(pos.z, 2))
	ang = Angle(math.Round(ang.p, 2), math.Round(ang.y, 2), math.Round(ang.r, 2))

	if self.SavedPos != pos or self.SavedAng != ang then
		return true
	end

	return false
end

function ENT:SaveMoved()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	self.SavedPos = Vector(math.Round(pos.x, 2), math.Round(pos.y, 2), math.Round(pos.z, 2))
	self.SavedAng = Angle(math.Round(ang.p, 2), math.Round(ang.y, 2), math.Round(ang.r, 2))
end

function ENT:OnRemove()
	if CLIENT then
		return
	end

	local item = self.Item

	-- self.Item gets nulled out first if the item is being removed by other means, e.g. unloading or being picked up
	if item and not GAMEMODE.IsShuttingDown then
		item:Delete()
	end
end

function ENT:Use(activator, caller, usetype, val)
	local item = self.Item

	if not item then
		return
	end

	item:OnWorldUse(activator)
end

function ENT:CanTool(ply, tool)
	if SERVER and tool == "remover" then
		Log.Write("item_destroy", ply, self.Item)
	end

	return true
end
