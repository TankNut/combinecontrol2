AddCSLuaFile()
DEFINE_BASECLASS("cc_spawnpoint")

ENT.Base = "cc_spawnpoint"

ENT.PrintName = "Team Spawn"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Spawnpoints"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Mode = SPAWN_TEAM

ENT.Actions = {}
ENT.Actions.SetSpawnTeam = {
	Name = "Set Team",

	Access = ACTION_EDITMODE,
	Target = ACTION_INTERACT,

	CanRun = function(self, ply) return not self:IsSaved() end,

	SubOptions = function(self, ply)
		local options = {}

		for id, team in ipairs(Team.List) do
			table.insert(options, {
				Name = team.Name,
				Value = id
			})
		end

		return options
	end,
	Validate = function(self, ply, id)
		return tobool(Team.List[id])
	end,

	Callback = function(self, ply, id)
		self:SetTeam(id)
	end
}

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("Int", "Team")
	self:SetTeam(-1)
end

function ENT:CanSave()
	return self:GetTeam() != -1
end

if CLIENT then
	function ENT:GetModelColor()
		if self:IsBlocked() then
			return self.BadColor
		end

		local teamID = self:GetTeam()

		if teamID == -1 then
			return self.BadColor
		end

		return team.GetColor(teamID)
	end

	function ENT:GetLabel()
		local teamID = self:GetTeam()

		if teamID == -1 then
			return "*INVALID*"
		end

		return team.GetName(teamID)
	end
else
	function ENT:GetSaveData()
		return {
			Team = self:GetTeam()
		}
	end

	function ENT:LoadSaveData(data)
		self:SetTeam(data.Team)
	end
end
