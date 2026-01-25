AddCSLuaFile()

ENT.Type = "anim"

function ENT:Initialize()
	self:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)

	self.Parent = self:GetParent()
	self.LocalPos = self:GetLocalPos()
	self.LocalAng = self:GetLocalAngles()
end

function ENT:SetupDataTables()
	self:NetworkVar("Int", "AttachmentID")
end

function ENT:GetType()
	if self:IsEffectActive(EF_BONEMERGE) then
		return ATTACH_BONEMERGE
	elseif self:IsEffectActive(EF_FOLLOWBONE) then
		return ATTACH_FOLLOW_BONE
	else
		return ATTACH_FOLLOW
	end
end

if CLIENT then
	function ENT:Think()
		if self:GetParent() != self.Parent then
			self:SetParent(self.Parent, self:GetAttachmentID())

			self:SetLocalPos(self.LocalPos)
			self:SetLocalAngles(self.LocalAng)
		end

		self:SetNextClientThink(CurTime())

		return true
	end

	function ENT:Draw(flags)
		local shouldDraw = true

		-- We're a honest to god entity, so our parent is too (nothing vgui related), so we do some extra checks to see if we should bother drawing
		if self:EntIndex() != -1 then
			local parent = self:GetParent()

			if parent:GetNoDraw() or not parent:Alive() then
				shouldDraw = false
			elseif parent == lp and not parent:ShouldDrawLocalPlayer() then
				shouldDraw = false
			end
		end

		if shouldDraw then
			self:DrawModel(flags)
			self:CreateShadow()
		else
			self:DestroyShadow()
		end
	end
end
