EntityVar.Add("FakePlayer", {Default = NULL})
EntityVar.Add("FakeAppearance", {Default = {}})

PlayerVar.Add("FakeEntity", {Default = NULL})

local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

function PLAYER:IsRagdolled()
	return IsValid(self:FakeEntity())
end

function PLAYER:GetRagdoll()
	return self:FakeEntity()
end

if SERVER then
	function PLAYER:StartRagdoll()
		local ragdoll = ents.Create("prop_ragdoll")

		ragdoll:SetPos(self:GetPos())
		ragdoll:SetAngles(self:GetAngles())

		ragdoll:SetFakeAppearance(self:Appearance())

		ragdoll:Spawn()
		ragdoll:Activate()

		ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		self:SetFakeEntity(ragdoll)

		return rag
	end

	function PLAYER:EndRagdoll()
		if not self:IsRagdolled() then
			return
		end

		local ragdoll = self:GetRagdoll()

		self:SetPos(ragdoll:GetPos())

		ragdoll:Remove()

		self:SetFakeEntity(nil)
	end
end

function ENTITY:IsFakePlayer()
	return IsValid(self:FakePlayer())
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

function GM:OnFakeEntityChanged(ply, old, new, loaded)
	if IsValid(old) then
		old.GetPlayerColor = nil
	end

	if IsValid(new) then
		new.GetPlayerColor = function()
			return ply:GetPlayerColor()
		end
	end
end
