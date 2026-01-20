local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

function PLAYER:IsRagdolled()
	return IsValid(self:GetRagdoll())
end

function PLAYER:GetRagdoll()
	return self:GetNWEntity("Ragdoll")
end

if SERVER then
	function PLAYER:StartRagdoll()
		self:SetNoTarget(true)
		self:SetNotSolid(true)
		self:SetNoDraw(true)

		self:SetMoveType(MOVETYPE_NOCLIP)

		if self:FlashlightIsOn() then
			self:Flashlight(false)
		end

		self:SetActiveWeapon(nil)

		local ragdoll = ents.Create("prop_ragdoll")

		ragdoll:SetPos(self:GetPos())
		ragdoll:SetAngles(self:GetAngles())

		self:CopyModel(ragdoll)
		self:CopyAttachments(ragdoll)

		ragdoll:Spawn()
		ragdoll:Activate()

		self:SetNWEntity("Ragdoll", ragdoll)
		ragdoll:SetNWEntity("FakePlayer", self)

		return rag
	end

	function PLAYER:EndRagdoll()
		if not self:IsRagdolled() then
			return
		end

		local ragdoll = self:GetRagdoll()

		self:SetPos(ragdoll:GetPos())
		self:SetNWEntity("Ragdoll", NULL)

		ragdoll:SetNWEntity("FakePlayer", nil)
		ragdoll:Remove()

		self:SetActiveWeapon(self:GetWeapons()[1])

		self:SetMoveType(MOVETYPE_WALK)

		self:SetNotSolid(false)
		self:SetNoTarget(false)
		self:SetNoDraw(false)
	end
end

function ENTITY:IsFakePlayer()
	return IsValid(self:GetFakePlayer())
end

function ENTITY:GetFakePlayer()
	return self:GetNWEntity("FakePlayer")
end
