module("part", package.seeall)

function LookupBone(ent, id)
	local mat = ent:GetBoneMatrix(id)

	if not mat then
		return
	end

	local pos = mat:GetTranslation()
	local ang = mat:GetAngles()
	ang:CheckNaN()

	if ent:GetClass() == "viewmodel" then
		local owner = ent:GetOwner()

		if owner:IsPlayer() then
			local weapon = owner:GetActiveWeapon()

			if IsValid(weapon) and weapon.ViewModelFlip then
				ang.r = -ang.r
			end
		end
	end

	return pos, ang
end

function GetBone(ent, bone)
	if not IsValid(ent) then
		return Vector(), Angle()
	end

	ent:SetupBones()

	if bone == "_pos_ang" or bone == "" then
		return ent:GetPos(), ent:GetAngles()
	end

	local pos, ang
	local boneId = ent:LookupBone(bone)

	if boneId != nil then
		pos, ang = LookupBone(ent, boneId)
	end

	local attachId = ent:LookupAttachment(bone)

	if attachId != -1 then
		local attachment = ent:GetAttachment(attachId)

		if attachment then
			pos = attachment.Pos
			ang = attachment.Ang
		end
	end

	if not pos then pos = ent:GetPos() end
	if not ang then ang = ent:IsPlayer() and ent:EyeAngles():SetPitch(0) or ent:GetAngles() end

	return pos, ang
end
