AddCSLuaFile()

ENT.Base = "base_point"
ENT.Type = "point"

netvar.Add("ZoneShapes", {Default = {}})

function ENT:Initialize()
	zone.Effects[self] = true

	self.Shapes = {}
	self.Players = {}

	if SERVER then
		self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
	end
end

function ENT:OnRemove(fullUpdate)
	if fullUpdate then
		return
	end

	zone.Effects[self] = nil

	for effect in pairs(self.Shapes) do
		effect.Effects[self] = nil
	end
end

function ENT:GetZOrder()
	return self:EntIndex()
end

function ENT:AffectsPlayer(ply)
	return true
end

function ENT:AddShape(shape)
	self.Shapes[shape] = true
	shape.Effects[self] = true

	if SERVER then
		netvar.Set(self, "ZoneShapes", self.Shapes)
	end
end

function ENT:Enter(ply, transition)
	print(ply, "Has entered", self, transition and "(transition)" or "")
end

function ENT:Exit(ply, transition)
	print(ply, "Has left", self, transition and "(transition)" or "")
end

function ENT:RemoveShape(shape)
	self.Shapes[shape] = nil
	shape.Effects[self] = nil
end

if CLIENT then
	hook.Add("OnZoneShapesChanged", "cc2.ZoneEffect", function(ent, old, new, loaded)
		if not ent:IsType("zone_effect_base") then
			return
		end

		for shape in pairs(old) do
			ent:RemoveShape(shape)
		end

		for shape in pairs(new) do
			ent:AddShape(shape)
		end
	end)
else
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end
end
