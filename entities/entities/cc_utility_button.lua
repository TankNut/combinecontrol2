DEFINE_BASECLASS("cc_worldent_picker")
AddCSLuaFile()

ENT.Base = "cc_worldent_picker"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Quick Button"
ENT.CCMainCategory = "World Entities"
ENT.CCSubCategory = "Utilities"

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Color = Color(200, 60, 255)

EntityCache.Add("worldents_quickbuttons", function(ent) return ent:IsType("cc_utility_button") end)

local validation = {
	validate.Max(32)
}

ENT.Actions = {}
ENT.Actions.SetButton = {
	Name = "Set Button ID",

	EditMode = true,
	Interaction = true,

	CanRun = function(self, ply) return not self:IsSaved() end,
	Validate = function(self, ply, name)
		return validate.Value(name, validation)
	end,
	Client = function(self, ply)
		return true, GUI.Open("Input", "string", "Set Button ID", {
			Default = self:GetButtonID(),
			Validate = validation,
			Name = "Button ID"
		})
	end,
	Callback = function(self, ply, id)
		self:SetButtonID(id)
	end
}

Action.Add("QuickButton", {
	Name = "Admin Utilities/Quick Button",

	Self = true,
	Context = "Admin",

	CanRun = FindMetaTable("Player").IsAdmin,
	SubOptions = function(self, ply)
		local options = {}

		for ent in pairs(EntityCache.Get("worldents_quickbuttons")) do
			if not ent:IsSaved() then
				continue
			end

			table.insert(options, {
				Name = ent:GetButtonID(),
				Value = ent
			})
		end

		table.sort(options, function (left, right)
			return left.Value:GetButtonID() < right.Value:GetButtonID()
		end)

		if lp:EditMode() then
			table.insert(options, 1, {
				Name = "Create Quick Button...",
				Value = nil
			})
		end

		return options
	end,

	Validate = function(self, ply, ent)
		return IsValid(ent) and ent:IsType("cc_utility_button") and ent:IsSaved()
	end,
	Client = function(self, ply, ent)
		if not ent then
			ply:ConCommand("gm_spawnsent cc_utility_button")

			return false
		end

		return true, ent
	end,
	Callback = function(self, ply, ent)
		ent:GetPickedEntity():Use(ply)
	end
})

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("String", "ButtonID")
end

function ENT:CanSave()
	if not BaseClass.CanSave(self) then
		return false
	end

	for ent in pairs(EntityCache.Get("worldents_quickbuttons")) do
		if self != ent and self:GetButtonID() == ent:GetButtonID() then
			return false
		end
	end

	return #self:GetButtonID() > 0
end

if CLIENT then
	function ENT:GetLabel()
		local name = self:GetButtonID()

		if #name > 0 then
			return "Button: " .. name
		else
			return "Button: *INVALID*"
		end
	end

	function ENT:DrawTranslucent()
		BaseClass.DrawTranslucent(self)

		if self:ShouldDraw() then
			render.DrawWorldText(self:LocalToWorld(Vector(0, 0, self:GetModelRadius() + 8)), self:GetLabel())
		end
	end
else
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:GetSaveData()
		return {
			ButtonID = self:GetButtonID()
		}
	end

	function ENT:LoadSaveData(data)
		self:SetButtonID(data.ButtonID)
	end
end
