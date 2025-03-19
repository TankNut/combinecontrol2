AddCSLuaFile()

function SWEP:PlayAnimation(name)
	local ply = self:GetOwner()

	if not IsValid(ply) or not ply:IsPlayer() then
		return
	end

	local vm = ply:GetViewModel()
	local func = self["Get" .. name .. "Animation"]
	local animation = func and func(self) or self.Animations[name]

	local index = isnumber(animation) and vm:SelectWeightedSequence(animation) or vm:LookupSequence(animation)

	vm:SendViewModelMatchingSequence(index)

	return vm:SequenceDuration(index)
end

function SWEP:GetHolsterAnimation()
	return self:GetHolstered() and ACT_VM_HOLSTER or ACT_VM_DRAW
end
