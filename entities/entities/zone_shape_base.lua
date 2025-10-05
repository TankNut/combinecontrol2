AddCSLuaFile()

ENT.Base = "base_point"
ENT.Type = "point"

ENT.Color = Color(0, 100, 0, 50)
ENT.OutlineColor = Color(0, 255, 0)

function ENT:Initialize()
	zone.Shapes[self] = true

	self.Effects = {}

	if SERVER then
		self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
	end
end

function ENT:OnRemove(fullUpdate)
	if fullUpdate then
		return
	end

	zone.Shapes[self] = nil

	for effect in pairs(self.Effects) do
		effect.Shapes[self] = nil
	end
end

function ENT:GetHull(ply)
	local pos = ply:GetPos()
	local pMins, pMaxs = ply:Crouching() and ply:GetHullDuck() or ply:GetHull()

	pMins:Add(pos)
	pMaxs:Add(pos)

	return mins, maxs
end

function ENT:Contains(ply)
	return false
end

if CLIENT then
	function ENT:DrawShape()
	end
else
	function ENT:Setup(...)
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end
end
