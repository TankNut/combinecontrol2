EntityVar.Add("FakeAppearance", {Default = {}})

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

		self:SetMoveType(MOVETYPE_NOCLIP)

		if self:FlashlightIsOn() then
			self:Flashlight(false)
		end

		self:SetActiveWeapon(nil)

		local ragdoll = ents.Create("prop_ragdoll")

		ragdoll:SetPos(self:GetPos())
		ragdoll:SetAngles(self:GetAngles())

		ragdoll:SetFakeAppearance(self:Appearance())

		ragdoll:Spawn()
		ragdoll:Activate()

		ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)

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
	end
end

function ENTITY:IsFakePlayer()
	return IsValid(self:GetFakePlayer())
end

function ENTITY:GetFakePlayer()
	return self:GetNWEntity("FakePlayer")
end

function GM:OnFakeAppearanceChanged(ent, old, new, loaded)
	if CLIENT then
		part.Clear(ent)

		for name, data in pairs(new) do
			if name == "_base" then
				continue
			end

			local partType = data._type or "ModelPart"; data._type = nil

			if partType == "ModelPart" and data.Bonemerge == nil then
				data.Bonemerge = true
			end

			part.Add(ent, partType, name, data)
		end
	else
		ent:ApplyModel(new._base)
	end
end
