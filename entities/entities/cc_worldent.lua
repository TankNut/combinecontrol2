DEFINE_BASECLASS("cc_base_ent")
AddCSLuaFile()

ENT.Base = "cc_base_ent"

ENT.Physical = true

ENT.Actions = {}
ENT.Actions.SaveWorldEnt = {
	Name = "** Save **",
	Priority = -10,

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return self:CanSave() and not self:IsSaved() end,

	Callback = function(self, ply)
		WorldEnts.Save(self)
	end
}

ENT.Actions.DeleteWorldEnt = {
	Name = "** Delete **",
	Priority = -10,

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return self:IsSaved() end,

	Callback = function(self, ply)
		WorldEnts.Delete(self)
	end
}

EntityCache.Add("worldents", function(ent) return ent:IsType("cc_worldent") end)

if SERVER then
	function ENT:SpawnFunction(ply, tr, class)
		if not ply:EditMode() then
			ply:SendChat("ERROR", "You have to be in edit mode to do this!")

			return
		end

		return BaseClass.SpawnFunction(self, ply, tr, class)
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", "EntityID")
end

function ENT:IsSaved()
	return self:GetEntityID() > 0
end

function ENT:IsProtectedEntity()
	return self:IsSaved()
end

function ENT:CanSave()
	return true
end

function ENT:CanPhys(ply)
	return not self:IsSaved()
end

function ENT:CanTool(ply, tr, tool)
	return not self:IsSaved()
end

if CLIENT then
	function ENT:ShouldDraw()
		return lp:EditMode() or not self:IsSaved()
	end
else
	function ENT:PreSaveEntity()
	end

	function ENT:GetSaveData()
		return {}
	end

	function ENT:LoadSaveData(data)
	end

	function ENT:PostInitData()
		self:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)
		self:PhysFreeze()

		if not self.Physical then
			self:DrawShadow(false)
			self:SetMoveType(MOVETYPE_NONE)
			self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		end
	end
end
