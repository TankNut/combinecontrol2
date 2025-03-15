AddCSLuaFile()
DEFINE_BASECLASS("cc_spawnpoint")

ENT.Base = "cc_spawnpoint"

ENT.PrintName = "Group Spawn"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Spawnpoints"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Mode = SPAWN_GROUP

local validation = {
	validate.Max(32)
}

ENT.Actions = {}
ENT.Actions.SetSpawngroup = {
	Name = "Set Spawngroup",

	EditMode = true,
	Interaction = true,

	CanRun = function(self, ply) return not self:IsSaved() end,
	Validate = function(self, ply, name)
		return validate.Value(name, validation)
	end,
	Client = function(self, ply)
		return true, GUI.Open("Input", "string", "Change Spawngroup", {
			Default = self:GetGroup(),
			Validate = validation,
			Name = "Spawn groups"
		})
	end,
	Callback = function(self, ply, name)
		self:SetGroup(name)
	end
}

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("String", "Group")
end

function ENT:CanSave()
	return #self:GetGroup() > 0
end

if CLIENT then
	local colorTable = {}

	function ENT:GetModelColor()
		if self:IsBlocked() then
			return self.BadColor
		end

		local group = self:GetGroup()

		if #group == 0 then
			return self.BadColor
		end

		if not colorTable[group] then
			local crc = util.CRC(group)

			math.randomseed(crc)
			colorTable[group] = HSVToColor(math.random(360), 0.5, 1)
			math.randomseed(os.time())
		end

		return colorTable[group]
	end

	function ENT:GetLabel()
		local group = self:GetGroup()

		if #group == 0 then
			return "*INVALID*"
		end

		return group
	end
else
	function ENT:GetSaveData()
		return {
			Group = self:GetGroup()
		}
	end

	function ENT:LoadSaveData(data)
		self:SetGroup(data.Group)
	end
end
