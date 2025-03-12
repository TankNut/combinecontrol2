AddCSLuaFile()

ENT.Base = "cc_base_ent"

ENT.IsWorldEntity = true

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
	self:NetworkVar("Int", 0, "EntityID")
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

if SERVER then
	function ENT:GetSaveData()
		return {}
	end

	function ENT:LoadSaveData(data)
	end

	function ENT:PostInitData()
	end
end
